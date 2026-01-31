# ApexCore Vault 🛡️

ApexCore is a smart contract Vault based on the **ERC-4626** standard. It is designed to manage user assets securely with built-in fee mechanisms.

**Current Status:** Level 1 Completed (Fee Manager)

## 🚀 Features

### 1. Fee Manager (The Capitalist)
- Automatically collects a **2% Fee** on every deposit.
- Uses **Basis Points (BPS)** for precise math.
- Fees are sent directly to the Vault Owner.

## 🛠 Tech Stack
- **Language:** Solidity ^0.8.20
- **Framework:** Foundry (Forge)
- **Security:** OpenZeppelin Contracts

## 🧪 How to Test
Run the following command to see the fee logic in action:
```bash
forge test -vv
