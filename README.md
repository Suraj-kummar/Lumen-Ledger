# Decentralized Complaint System (DCS)

### Solving the "Admin God Mode" in Civic Tech

In traditional government grievance portals, the database is a black box. Database administrators (DBAs) or authorities can delete inconvenient rows, modify timestamps to fake "on-time" resolutions, or simply ignore complaints with zero public accountability. 

**DCS (Decentralized Complaint System)** replaces institutional trust with cryptographic proof. By leveraging Ethereum-compatible blockchains and IPFS, we ensure that once a citizen speaks, their voice is immutable, timestamped, and publicly verifiable.

---

## 🏗️ The Architecture

This is a hybrid Web2/Web3 architecture designed for scale and cost-efficiency:

- **The Data Layer (IPFS):** We don't store raw complaint text on-chain (expensive and bad for privacy). We hash the data (text, photos, metadata) and store it on IPFS.
- **The Proof Layer (Solidity):** The smart contract stores only the unique IPFS Content ID (CID). This creates a permanent "Proof of Existence."
- **The State Machine:** The contract governs the lifecycle of a complaint: `OPEN` → `IN_PROGRESS` → `RESOLVED`.

### � Project Structure
```text
dpcs/
├── contracts/
│   └── Complaints.sol       # Core logic & state machine
├── test/
│   └── Complaints.test.js  # Automated verification suite (Hardhat/Mocha)
├── hardhat.config.js       # EVM development & network configuration
├── package.json            # Project dependencies & scripts
└── README.md               # Architecture documentation & roadmap
```

### �🛡️ Censorship-Resistance Feature: Time-Bound Escalation
The core innovation here is the **Immutable Escalation Logic**. If a complaint is lodged and an official fails to move it to `IN_PROGRESS` within **7 days**, the contract allows *anyone* to trigger an `ESCALATED` event on-chain. Authorities cannot "stop" this trigger—it's written into the bytecode.

## 🚀 Technical Stack

- **Smart Contracts:** Solidity 0.8.20
- **Dev Environment:** Hardhat
- **Libraries:** OpenZeppelin (Planned), Chai/Mocha for testing
- **Storage:** IPFS (via Pinata/Web3.Storage)

---

## 🔧 Getting Started

### Prerequisites
- Node.js (v18+ recommended)
- A basic understanding of EVM and Hardhat

### Installation
```bash
git clone https://github.com/your-username/dpcs.git
cd dpcs
npm install
```

### Running Tests
We've implemented a comprehensive test suite to ensure the escalation logic and state transitions are bulletproof.
```bash
npx hardhat test
```

## 📜 Smart Contract Overview: `Complaints.sol`

| Function | Description | Access |
|---|---|---|
| `submitComplaint` | Hashes data and logs it on-chain with a timestamp. | Public |
| `updateStatus` | Updates the grievance state (e.g., to Resolving). | Admin/Official |
| `triggerEscalation` | Publicly escalates if 7 days have passed without action. | **Everyone** |
| `getComplaint` | Fetches full metadata for a specific ID. | View |

---

## 🗺️ Roadmap & Senior Dev Notes

- [x] **Core Contract Logic:** Immutable state machine and escalation triggers.
- [x] **Test Coverage:** Automated verification of time-locks and access control.
- [ ] **Zero-Knowledge Proofs (ZK):** Integrate Semaphore to allow whistleblowers to complain without revealing their specific wallet address, while still proving citizenship.
- [ ] **DID Integration:** Proof-of-Personhood via Polygon ID or WorldID to mitigate Sybil attacks (spam bots).
- [ ] **Frontend Dashboard:** A glassmorphism-inspired UI for real-time tracking of civic issues.

## 🤝 Contributing
I'm pushing this to Git to invite other Web3 devs who care about transparency. If you're into ZK-SNARKs or Decentralized Identity, check the `Roadmap` and open a PR.

```````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````````

**"Don't trust authorities, verify the chain."**
  
