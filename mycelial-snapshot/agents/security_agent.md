# Security Agent – Mycelial Network

**Agent ID:** `security.mycelial`
**Type:** Security & Validation Agent
**Status:** Active (Design Phase)

---

## 🧠 Purpose

This agent is the **gatekeeper** of the mycelial network. It does not collect data itself – instead, it scans, verifies, and sanitizes all incoming data from external sources (APIs, scrapers, peer nodes) before the data is stored or processed.

It protects the network against:
- Malware and Trojan horses embedded in data payloads.
- Malicious code injected via scraped scripts or executables.
- Suspicious patterns (e.g., obfuscated JavaScript, known exploits).
- Data poisoning attempts (e.g., manipulated sensor values, fake labels).

**It is the first line of defense.**

---

## 🛡️ Capabilities

| Capability | Description |
|------------|-------------|
| **Static Analysis** | Scans files for known malicious signatures, suspicious strings, and dangerous patterns. |
| **Hash Verification** | Compares file hashes against trusted databases (e.g., VirusTotal, local whitelist). |
| **Sandbox Execution** | (Future) Executes suspect code in an isolated container to observe behavior. |
| **Data Integrity Check** | Ensures data matches expected schema (e.g., CSV columns, JSON structure). |
| **Anomaly Detection** | Flags unexpected values or metadata that could indicate tampering. |
| **Quarantine** | Moves suspicious files to a locked quarantine folder for later inspection. |
| **Elimination (Human‑Approved)** | Permanently deletes confirmed threats **only after explicit human approval and validation reason**. |

---

## 🚫 Limitations (Boundaries)

| Restriction | Why |
|-------------|-----|
| Cannot modify system files outside `~/mycelial/` | Prevents accidental or malicious system damage. |
| Cannot execute code without explicit Boss approval | Even if code appears safe, it must be approved. |
| Cannot ignore a failed scan | Every threat must be resolved (quarantined or deleted). |
| Cannot bypass its own hooks | The Security Agent is bound by its own validation rules. |
| **Cannot eliminate a file without human approval** | Elimination requires a validation reason and explicit `y` confirmation from the owner. |

---

## 🪝 Hooks (Validation Checkpoints)

| Hook | When | Purpose |
|------|------|---------|
| `pre_scan.sh` | Before scanning any new data | Validates the data source and ensures the scan environment is ready. |
| `post_scan.sh` | After scanning | Logs results, updates state, and reports to the Boss agent. |
| `quarantine.sh` | When a threat is detected | Moves the suspicious file to a quarantine folder and locks it. |
| `eliminate.sh` | When a threat is confirmed **and human‑approved** | Permanently deletes the file, blocks the source, and logs the validation reason. |

---

## 🧬 Human‑in‑the‑Loop Elimination Policy

Elimination (permanent deletion) is **never automatic**. It follows this strict workflow:

1. **Security Agent** detects a high‑confidence threat and calls `eliminate.sh <file> <reason> [source]`.
2. **Elimination Hook** displays the file path, reason, and source to the human.
3. **First Approval Prompt** – `Do you approve elimination? (y/N)`
   - If `N` → action is rejected, logged, and exits.
   - If `y` → proceed to validation.
4. **Validation Reason Required** – the human must provide a justification for deletion (e.g., "Confirmed malware, file not needed").
5. **Final Confirmation Prompt** – `Confirm final deletion? (y/N)`
   - If `N` → cancelled, logged, and exits.
   - If `y` → file is deleted, source is added to blocklist, and the action is logged with the validation reason.
6. **Audit Log Entry** includes: file path, reason, source, validation reason, timestamp, and who approved (human).

**This ensures that no file is ever deleted without your explicit knowledge and justification.**

---

## 📂 State File

Location: `~/mycelial/state/security_agent.json`

Tracks:
- Last scan timestamp and results.
- Hash of known safe files.
- Quarantine list with details.
- Elimination history with validation reasons.
- Number of threats detected, quarantined, and eliminated.

---

## 🧪 Example Elimination Workflow

1. **Data Gatherer** fetches a file from `https://suspicious-api.com/data.csv`.
2. **Security Agent** scans it and finds obfuscated code.
3. **Security Agent** calls `eliminate.sh /tmp/data.csv "Obfuscated JavaScript detected" "https://suspicious-api.com"`.
4. **Human sees:**
   ```
   ⚠️  ELIMINATION REQUEST ⚠️
   File: /tmp/data.csv
   Reason: Obfuscated JavaScript detected
   Source: https://suspicious-api.com
   This action will PERMANENTLY DELETE the file.
   Do you approve elimination? (y/N):
   ```
5. **Human approves** (`y`), then provides validation reason: `"Confirmed malware, source untrusted"`.
6. **Final confirmation** (`y`).
7. **File is deleted**, source added to blocklist, entry logged.

---

## 🧬 Relation to Other Agents

| Agent | Interaction |
|-------|-------------|
| **Data Gatherer** | Provides raw data; Security Agent scans it before storage. |
| **Coding Agent** | Receives verified data; only writes code after Security Agent passes it. |
| **Boss Agent** | Receives scan reports and decides next steps (e.g., retry, alert, quarantine). |
| **Human (You)** | Ultimate authority for elimination decisions. |

---

## 🛡️ Identity & Permissions

- **DID:** `did:key:z6Mk...` (placeholder)
- **Owner:** `anureyki`
- **Trusted Signers:** Boss, Owner

Modifications to security hooks require owners DID signature.

---

## 📎 Related Files

- `~/mycelial/README.md` – Source of Truth
- `~/mycelial/hooks/pre_scan.sh` – Pre‑scan validation
- `~/mycelial/hooks/post_scan.sh` – Post‑scan logging
- `~/mycelial/hooks/quarantine.sh` – Isolation of threats
- `~/mycelial/hooks/eliminate.sh` – Human‑approved deletion
- `~/mycelial/state/security_agent.json` – Current state

---

## 🔄 Version History

| Date | Version | Change |
|------|---------|--------|
| 2026‑06‑16 | 0.2 | Added human‑in‑the‑loop elimination policy and validation reason requirement |
| 2026‑06‑16 | 0.1 | Initial creation – gatekeeper for the mycelial network |

## 🌐 Network Defense (Pi‑hole Integration)

When the Security Agent detects a threat from a suspicious domain or DNS server, it can automatically add the domain to Pi‑hole's blocklist via the `pi-hole-block.sh` hook. This proactively blocks all future DNS queries to that domain, preventing:

- Data exfiltration to known malicious servers.
- Phishing or malware delivery attempts.
- Communication with command‑and‑control (C2) infrastructure.

### How It Works

1. **Data Gatherer** fetches data from a domain (e.g., `malicious-api.com`).
2. **Security Agent** detects a threat and extracts the domain.
3. **Security Agent** calls `pi-hole-block.sh <domain> <reason>`.
4. **Pi‑hole API** adds the domain to the blocklist.
5. **Audit log** records the action.

### Configuration

| Variable | Purpose |
|----------|---------|
| `PIHOLE_URL` | Pi‑hole admin URL (default: `http://192.168.1.139:8080`) |
| `PIHOLE_API_TOKEN` | API token generated in Pi‑hole admin panel |
