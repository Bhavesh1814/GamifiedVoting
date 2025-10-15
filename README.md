# 🗳️ Gamified Voting System

A smart contract built on **Flow EVM Testnet** that gamifies the voting process by rewarding users for engagement and participation.  
The more you engage, the stronger your voting power becomes!

---

## 🌐 Deployment Details

- **Network:** Flow EVM Testnet  
- **Contract Address:** `0xC3F32e4A75cE4713d32F55Fbd3b6f7d32EBbF4e2`  
- **Language:** Solidity (`^0.8.19`)  
- **Framework:** Remix IDE  
- **No imports**, **no constructor**, and **no input fields** for core functions.

---

## ⚙️ Overview

This contract allows users to:
- **Engage** regularly to earn XP (Experience Points)
- **Increase voting power** based on XP and engagement streaks
- **Vote** for fixed choices (A, B, or C)
- **Earn rewards** for each vote
- **Claim** their accumulated rewards

The system encourages consistent engagement by linking XP growth to voting influence.

---

## 🧩 Core Features

| Feature | Description |
|----------|-------------|
| 🏆 **Engagement System** | Call `engage()` to gain XP and build streaks |
| 💪 **Dynamic Voting Power** | Voting power increases with XP and streak bonuses |
| 🗳️ **Voting** | Vote using `voteA()`, `voteB()`, or `voteC()` |
| 🎁 **Rewards** | Every vote and engagement adds to your in-contract balance |
| 🔐 **Claimable Ownership** | Ownership is claimed post-deployment using `claimOwnership()` |
| 🏁 **Election Lifecycle** | Owner can `startElection()` and `endElection()` to control voting |

---

## 🚀 How to Interact (via Remix)

1. **Connect** Remix to **Flow EVM Testnet**
2. **Load** the deployed contract at the address:  
   `0xC3F32e4A75cE4713d32F55Fbd3b6f7d32EBbF4e2`
3. **Claim ownership** (if not yet claimed):  
   → `claimOwnership()`
4. **Start the election:**  
   → `startElection()`
5. **Engage to earn XP:**  
   → `engage()`
6. **Vote for your choice:**  
   → `voteA()` / `voteB()` / `voteC()`
7. **Check progress:**  
   → `xp(address)` / `rewardBalance(address)` / `votingPowerOf(address)`
8. **Claim your rewards:**  
   → `claimRewards()`
9. **End the election:**  
   → `endElection()`

---

## 📊 Voting Power Formula

Voting Power = Base Power (1)
+ (XP / 100) [max +10]
+ Streak Bonus (up to +3)
  
> The more you engage, the more powerful your vote becomes.

---

## 📜 Functions Summary

| Function | Purpose |
|-----------|----------|
| `claimOwnership()` | First caller becomes contract owner |
| `startElection()` | Owner starts the election |
| `endElection()` | Owner ends the election |
| `engage()` | Gain XP and streaks |
| `voteA()` / `voteB()` / `voteC()` | Cast votes |
| `claimRewards()` | Claim your reward balance |
| `votingPowerOf(address)` | View current power of a user |
| `totalVotes()` | Get total votes cast |
| `leadingChoice()` | View current leader |

---

## 💡 Future Enhancements

- Dynamic candidate list (add/remove choices)
- Real ERC20 reward token integration
- Web-based UI for engagement and voting
- Leaderboard and XP progression display

---

## 👨‍💻 Author

**Bhavesh Negi**  
Deployed on **Flow EVM Testnet**  
Built with ❤️ using Solidity and Remix IDE

---

















