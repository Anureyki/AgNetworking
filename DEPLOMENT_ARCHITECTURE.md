# Deployment Architecture for AgNetworking Node

## Overview
- Growers receive a **pre‑configured USB stick** with Rocky Linux 10 + full node software (IPFS, DID, encryption script).
- Boot from USB → node auto‑starts → watches for sensor data → encrypts + signs → uploads to private IPFS swarm.
- No installation, no command line required from the grower.

## Hardware & OS
- **Base OS:** Rocky Linux 10 (long‑term support until ~2030)
- **USB requirements:** USB 3.0+, persistent partition for grow logs and identity keys.
- **Update strategy:** 
  - **Golden image** – major updates via re‑flashing (preserve persistent data).
  - **Auto‑update agent** (future) for node software, IPFS, DID tools.

## Identity & Authentication (DID)
- Each USB contains a pre‑generated **Decentralized Identifier (DID)** (or the grower creates one on first boot).
- Private key stored encrypted on persistent partition (unlocked with a passphrase).
- Data signed with DID private key before upload; AI verifies signature using public DID document on IPFS.

## Data Pipeline
1. **Sensor input:** CSV files placed in a watched folder (e.g., via USB or network mount).
2. **Encryption:** Script applies differential privacy (Diffprivlib) + optionally GPG encryption.
3. **Signing:** Adds DID signature.
4. **Upload:** Pushes encrypted, signed blob to private IPFS swarm.
5. **Verification:** AI node fetches blob, verifies signature, then trains (decrypts in memory).

## IPFS Private Swarm
- Shared `swarm.key` for MVP, replaced later with DID‑based peer authentication.
- Two initial bootstrap nodes: Ubuntu server (central) and Rocky USB (test grower).

## Update Mechanism (Roadmap)
| Version | Update method | User action |
|---------|---------------|-------------|
| MVP | Re‑flash entire USB (preserve persistent partition) | Grower follows written instructions (e.g., `dd` or graphical tool) |
| v2 | Auto‑update agent (RPM package + cron) | None – automatic background updates |
| Major OS | Migration to Rocky 11 (manual, guided) | One‑time re‑flash (2030+) |

## Next Steps to Implement
- [ ] Build first USB image with Rocky 10 + IPFS + swarm key.
- [ ] Test two‑node swarm (Ubuntu server + USB).
- [ ] Integrate DID generation (e.g., `did:cid` or `did:ipid`) into node software.
- [ ] Write auto‑update agent (optional for v2).

## Related Documents
- [IPFS Private Setup](IPFS_PRIVATE_SETUP.md)
- [Tokenization Roadmap](TOKENIZATION_ROADMAP.md)
- [Privacy Stack](privacy-stack.md)

---
*This document captures design decisions for the deployment and update strategy. Update as the architecture evolves.*
