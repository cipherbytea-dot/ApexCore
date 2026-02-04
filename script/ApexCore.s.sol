// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ApexCore} from "../src/ApexCore.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MCK") {}
    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract CounterScript is Script {
    ApexCore public vault;
    MockERC20 public token;

    address public owner = address(0x123);

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        token = new MockERC20();
        vault = new ApexCore(token, owner);

        vm.stopBroadcast();
    }
}
