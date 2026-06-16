# Mycelial Network – Source of Truth

This directory is the immutable source of truth for all mycelial agents.

## Directories
- `agents/` – agent definitions, identities, and permissions
- `hooks/` – pre/post validation scripts (signed with DID)
- `state/` – current state of each node and project
- `logs/` – immutable audit logs (pinned to IPFS)
- `sources/` – cached legal, regulatory, and reference documents
- `projects/` – active projects (LLC, S-Corp, grow logs, etc.)

## Rules for Agents
1. Any agent must read this README before taking action.
2. Any agent must verify hooks before executing them.
3. No agent may modify hooks without a valid DID signature.
4. All state changes must be logged to `logs/`.

## Projects
- [ ] LLC formation (complete)
- [ ] S-Corp election (in progress)
- [ ] Grow log #1 (waiting for CSV)
- [ ] AI Engineering certificate (in progress)
