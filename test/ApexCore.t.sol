// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {ApexCore} from "../src/ApexCore.sol";
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

// 1. Kita bikin Token Palsu buat mainan (Mock Token)
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

    // --- SETUP: Dijalankan sebelum setiap test ---
    function setUp() public {
        // 1. Deploy Token Palsu
        token = new MockERC20();

        // 2. Deploy Vault Kita (ApexCore)
        // Asset: token, Owner: address(0x1)
        vault = new ApexCore(token, owner);

        // 3. Kasih Alice duit jajan 1000 token
        token.mint(alice, 1000 ether);
    }

    // --- TEST: Cek apakah Fee Deposit jalan? ---
    function testDepositTakesFee() public {
        uint256 depositAmount = 100 ether; // Alice mau deposit 100
        
        // Mulai sandiwara sebagai Alice
        vm.startPrank(alice);
        
        // Alice setujui (Approve) Vault buat narik duitnya
        token.approve(address(vault), depositAmount);
        
        // Alice melakukan Deposit
        vault.deposit(depositAmount, alice);
        
        vm.stopPrank(); // Selesai sandiwara

        // --- MATEMATIKA ---
        // Fee 2% dari 100 = 2
        // Bersih = 98
        uint256 expectedFee = 2 ether;
        uint256 expectedNet = 98 ether;

        // --- ASSERT (PENGECEKAN) ---
        
        // 1. Cek saldo Owner (Harus nambah 2 token)
        uint256 ownerBalance = token.balanceOf(owner);
        assertEq(ownerBalance, expectedFee, "Owner harus dapet Fee 2%");

        // 2. Cek saldo Vault (Harus cuma nerima 98 token)
        uint256 vaultBalance = token.balanceOf(address(vault));
        assertEq(vaultBalance, expectedNet, "Vault harus nerima jumlah bersih");

        // 3. Cek Share Alice (Alice harus dapet bukti kepemilikan senilai 98)
        uint256 aliceShare = vault.balanceOf(alice);
        assertEq(aliceShare, expectedNet, "Share Alice harus sesuai nilai bersih");
        
        console.log("Test Berhasil! Owner dapet cuan:", ownerBalance);
    }
}