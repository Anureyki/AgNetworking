# AgNetworking Ecosystem Architecture

```mermaid
graph TD
    subgraph "Grower Node (Rocky Linux USB)"
        A["Sensor CSV"] -->|watch folder| B["encrypt_and_send.py"]
        B -->|encrypt + sign| C["Encrypted Blob"]
        C -->|IPFS add| D["IPFS Node (private swarm)"]
        D -->|publish CID| E["DID Document (IPFS)"]
    end

    subgraph "Ubuntu Server (Central Bootstrap)"
        F["IPFS Node (private swarm)"]
        G["AI Training Pipeline"]
        H["DID Resolver + ZKP Verifier"]
        I["Token Reward Smart Contract"]
        J["Pi‑hole / DNS"]
    end

    subgraph "IPFS Private Swarm"
        D -->|swarm.key| F
    end

    subgraph "Data & Identity Flow"
        C -->|retrieve| G
        E -->|resolve| H
        H -->|verify signature| G
        G -->|proof of contribution| I
        I -->|AG tokens| K["Grower Wallet (DID)"]
    end

    subgraph "Key Technologies"
        L["Diffprivlib / ART"]
        M["DID:cid / did:ipid"]
        N["Zero‑Knowledge Proofs"]
        O["systemd / firewalld"]
    end

    B -.-> L
    H -.-> M
    H -.-> N
    F -.-> O
```

## Components Overview

### Grower Node (Rocky Linux USB)
- Watches for new sensor CSV files.
- Encrypts with Diffprivlib / GPG.
- Signs with grower’s DID private key.
- Uploads encrypted blob to private IPFS swarm.

### Ubuntu Server (Central Bootstrap)
- Runs IPFS node (bootstrap for private swarm).
- Resolves DIDs from IPFS.
- Verifies ZK proofs (or signatures).
- Trains AI on verified, encrypted data (decrypts in memory).
- Issues AG token rewards via smart contract.

### IPFS Private Swarm
- All nodes share the same `swarm.key` (temporary; will be replaced by DID‑based authentication).

### Identity & Privacy
- Each grower generates a **Decentralized Identifier (DID)** (e.g., `did:cid`).
- Zero‑Knowledge Proofs (ZKPs) allow verification of contribution without revealing raw data.

### Tokenization
- AI issues a proof of contribution → triggers smart contract → grower receives AG tokens.
- Tokens are utility tokens (reward for data contribution, not passive investment).

## Related Documents
- [IPFS Private Setup](IPFS_PRIVATE_SETUP.md)
- [Privacy Stack](privacy-stack.md)
- [Tokenization Roadmap](TOKENIZATION_ROADMAP.md)
- [Deployment Architecture](DEPLOYMENT_ARCHITECTURE.md)

---
*This diagram represents the current architecture (as of May 2026).*
