# 🏦 ApexCore Vault (ERC4626)

ApexCore is a robust Smart Contract Vault based on the **ERC4626** standard. It extends the standard implementation with built-in monetization mechanics and liquidity protection features.

## 🌟 Key Features

### 1. 🛡️ Time-Locked Withdrawals
To protect liquidity and prevent flash loan attacks, user deposits are subject to a mandatory locking period.
- **Lock Duration:** 3 Days (72 Hours).
- **Mechanism:** Users cannot execute `withdraw` or `redeem` until the lock period has passed since their last deposit.

### 2. 💸 Management Fee (Monetization)
An automated fee is applied to every deposit transaction.
- **Fee Rate:** 2% (200 BPS).
- **Flow:** The fee is deducted from the deposited assets and transferred directly to the contract `Owner`. The remaining assets (98%) are converted into Shares for the user.

### 3. 🔒 Standard ERC4626
- Fully compatible with the ERC4626 tokenized vault standard.
- Supports `deposit`, `mint`, `withdraw`, and `redeem` flows.
- Built on top of audited OpenZeppelin libraries.

---

## 🛠️ Tech Stack

- **Solidity:** ^0.8.20
- **Framework:** Foundry (Forge)
- **Dependencies:** OpenZeppelin Contracts

---

## 🚀 Getting Started

Ensure you have [Foundry](https://book.getfoundry.sh/) installed on your machine.

### 1. Clone & Install
```bash
git clone <YOUR_REPO_URL>
cd ApexCore
forge install