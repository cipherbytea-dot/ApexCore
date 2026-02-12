// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import {InsufficientTime} from "./customError.sol";

contract ApexCore is ERC4626, Ownable, ReentrancyGuard {
    using SafeERC20 for IERC20;

    uint256 private constant DEPOSIT_FEE_BPS = 200;
    uint256 private constant LOCK_TIME = 3 days;

    mapping(address => uint256) DepositTime;

    event FeeTaken(address indexed sender, uint256 feeAmount);

    constructor(IERC20 asset_, address initialOwner_)
        ERC4626(asset_)
        ERC20("Apex Core", "APC")
        Ownable(initialOwner_)
    {}

    function deposit(uint256 assets, address receiver) public override returns (uint256) {
        uint256 fee = (assets * DEPOSIT_FEE_BPS) / 10000;

        uint256 netAsset;

        unchecked {
            netAsset = assets - fee;
        }

        if (fee > 0) {
            SafeERC20.safeTransferFrom(IERC20(asset()), msg.sender, owner(), fee);
            emit FeeTaken(msg.sender, fee);
        }

        DepositTime[receiver] = block.timestamp;

        return super.deposit(netAsset, receiver);
    }

    function withdraw(uint256 assets, address receiver, address owner) public override nonReentrant returns (uint256) {
        uint256 depositTime = DepositTime[owner];

        if (block.timestamp < depositTime + LOCK_TIME) {
            revert InsufficientTime();
        }

        return super.withdraw(assets, receiver, owner);
    }

    function redeem(uint256 shares, address receiver, address owner) public override nonReentrant returns (uint256) {
        uint256 depositTime = DepositTime[owner];

        if (block.timestamp < depositTime + LOCK_TIME) {
            revert InsufficientTime();
        }

        return super.redeem(shares, receiver, owner);
    }
}
