// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ApexCore} from "../src/ApexCore.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MockERC20 is ERC20 {
    constructor() ERC20("Mock Token", "MCK") {}

    function mint(address to, uint256 amount) public {
        _mint(to, amount);
    }
}

contract ApexCoreTest is Test {
    ApexCore public vault;
    MockERC20 public token;

    address public owner = address(0x1);
    address public alice = address(0x2);

    uint256 public INITIAL_BALANCE = 5000 ether;

    function setUp() public {
        vm.startPrank(owner);

        token = new MockERC20();
        vault = new ApexCore(token, owner);

        token.mint(alice, INITIAL_BALANCE);

        vm.stopPrank();
    }

    function test_Deposit_BasicFlow() public {
        vm.startPrank(alice);
        token.approve(address(vault), INITIAL_BALANCE);

        uint256 depositAmount = 100 ether;
        uint256 sharesReceived = vault.deposit(depositAmount, alice);

        vm.stopPrank();

        assertGt(sharesReceived, 0); // Pastikan A lebih besar dari B
        assertEq(vault.balanceOf(alice), sharesReceived); // Pastikan A == B

        assertEq(token.balanceOf(alice), INITIAL_BALANCE - depositAmount);
    }

    function test_DepositTakeFeeCorrectly() public {
        vm.startPrank(alice);
        token.approve(address(vault), INITIAL_BALANCE);

        uint256 expectedNet = 98 ether;
        uint256 expectedFee = 2 ether;

        vault.deposit(100 ether, alice);
        vm.stopPrank();

        assertEq(token.balanceOf(owner), expectedFee);
        assertEq(vault.totalAssets(), expectedNet);
    }

    function test_Withdraw_RevertIfLocked() public {
        vm.startPrank(alice);
        token.approve(address(vault), INITIAL_BALANCE);
        vault.deposit(1000 ether, alice);

        vm.expectRevert();
        vault.withdraw(100 ether, alice, alice);

        vm.stopPrank();
    }

    function test_Withdraw_Success_AfterTimeTravel() public {
        vm.startPrank(alice);
        token.approve(address(vault), INITIAL_BALANCE);
        vault.deposit(100 ether, alice);

        uint256 aliceShares = vault.balanceOf(alice);
        assertGt(aliceShares, 0);

        vm.warp(block.timestamp + 3 days + 5 seconds);

        vault.withdraw(98 ether, alice, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 0);
        assertEq(token.balanceOf(alice), INITIAL_BALANCE - 2 ether);
    }

    function test_Redeem_RevertIfLocked() public {
        vm.startPrank(alice);
        token.approve(address(vault), INITIAL_BALANCE);
        vault.deposit(1000 ether, alice);

        vm.expectRevert();
        vault.redeem(1000 ether, alice, alice);

        vm.stopPrank();
    }

    function test_Redeem_Success_AfterTimeTravel() public {
        // Arrange
        // gas nyamar jadi alice
        vm.startPrank(alice);
        // deposit >> approve dulu
        token.approve(address(vault), INITIAL_BALANCE);
        vault.deposit(100 ether, alice);
        // cek dulu bahwa shares si alice > 0
        uint256 aliceShares = vault.balanceOf(alice);
        assertGt(aliceShares, 0);
        // Act
        // lewat waktu 3hari + 4 detik
        vm.warp(block.timestamp + 3 days + 5 seconds);
        // panggil fungsi redeem
        vault.redeem(98 ether, alice, alice);
        // stop nyamar
        vm.stopPrank();
        // Assert
        assertEq(vault.balanceOf(alice), 0);
        assertEq(token.balanceOf(alice), 4998 ether);
    }
}
