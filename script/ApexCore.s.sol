// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script} from "forge-std/Script.sol";
import {ApexCore} from "../src/ApexCore.sol";

contract CounterScript is Script {
    ApexCore public apex;

    function setUp() public {}

    function run() public {
        vm.startBroadcast();

        apex = new ApexCore();

        vm.stopBroadcast();
    }
}
