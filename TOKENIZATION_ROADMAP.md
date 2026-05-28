# Tokenization & Identity Roadmap for AgNetworking

## Current Status (Pre‑Tokenization)
- IPFS private swarm with single shared key (`swarm.key`) for test network.
- Data encryption + differential privacy (Diffprivlib) on grower nodes.
- AI training pipeline not yet connected to token rewards.

## Long‑Term Architecture (When Tokenization is Implemented)

### Identity: W3C Decentralized Identifiers (DIDs)
- Each grower will have their own DID (public‑private key pair).
- No shared secret; each node authenticates individually.
- DIDs will be resolvable on‑chain (custom DID method).
- Use open‑source libraries (e.g., `didlite`) for lightweight DID generation.

### Privacy & Proof: Zero‑Knowledge Proofs (ZKPs)
- Growers will prove they contributed valuable data without revealing raw sensor logs.
- ZKPs will be generated on the grower's node and verified by the tokenization layer.
- Use open ZKP frameworks (e.g., Hekate, Swanky, or Arkworks) – not vendor‑locked.

### Tokenization Layer: Sovereign Blockchain (Not Ripple/Stellar)
- AgNetworking will have its own blockchain, not built on top of XRP or XLM.
- Two possible frameworks:
  - **Substrate** (modular, Rust, can be standalone or Polkadot parachain)
  - **Cosmos SDK** (Go, IBC‑compatible, standalone sovereign chain)
- The chain will verify ZKPs and issue AG tokens to growers' DIDs.

## Phased Implementation Plan (For Future Reference)

| Phase | Goal | Technology | Timeline estimate |
|-------|------|------------|-------------------|
| **1. MVP** | Test reward logic on existing low‑fee chain | Ethereum L2 / Solana smart contract | After certs |
| **2. Sovereign testnet** | Run own chain with custom DID + ZKP pallets | Substrate or Cosmos SDK (single server) | 6‑12 months after Phase 1 |
| **3. Sovereign mainnet** | Public, decentralized validator set | Substrate (parachain) or Cosmos (standalone) | 12‑24 months after Phase 2 |

## Security Transition
- **Temporary (now)**: Single shared `swarm.key` for private IPFS network.
- **Future**: Each node uses its own DID; no shared secret. IPFS private network will be replaced by authenticated DIDs + ZKP‑verified data publication.

## Next Steps (For When Tokenization Phase Begins)
1. Research W3C DID methods and choose a lightweight implementation.
2. Select an open ZKP framework and write a test proof (e.g., "I have a valid sensor reading").
3. Deploy a simple smart contract on a testnet to verify proofs and mint tokens.
4. Begin building a custom Substrate or Cosmos SDK chain with `pallet_did` and `pallet_zkp_rewards`.

## Related Documents
- [Privacy Stack](privacy-stack.md) – current encryption & differential privacy.
- [Server Foundation](SERVER-FOUNDATION.md) – infrastructure.
- [Ecosystem Overview](ecosystem-overview.md) – economic flywheel.

---
*This document records design decisions and is not an active implementation plan. It will be updated when tokenization phase begins.*
