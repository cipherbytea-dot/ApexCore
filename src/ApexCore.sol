// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC4626} from "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

contract ApexCore is ERC4626, Ownable {
    using SafeERC20 for IERC20;

    // Definisikan Fee
    uint256 private constant DEPOSIT_FEE_BPS = 200;
    // Buat event untuk fee
    event FeeTaken(address indexed sender, uint256 feeAmount);
    // constructor
    constructor(IERC20 asset_, address initialOwner_) 
        ERC4626(asset_)
        ERC20("Apex Core", "APC")
        Ownable(initialOwner_)
    {}
        // Inisialisasi ERC20
        // Inisialisasi ERC4626
        // Inisialisasi owner()
    
    // Bikin fungsi deposit
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

        return super.deposit(netAsset, receiver);
    }
        // hitung fee
        // kurangi asset - fee
        // transfer fee ke owner
        // emit
        // panggil fungsi deposit
}