# 🍄 Empirical Connections – Mycelial AI Network

**Decentralized, privacy‑preserving AI for agriculture.**  
Growers keep raw sensor data. The network learns via federated learning + differential privacy.

---

## 🧠 Vision

A self‑organizing network of grower nodes – like mycelium. Each node trains locally on its own sensor data (temperature, humidity, CO₂, VPD, EC, pH). Only differentially private updates are shared. The global model predicts contamination and yield without exposing any single grower's data.

---

## 🛠️ What You Just Built

| Component | Technology | Status |
|-----------|------------|--------|
| Private data pipeline | CSV → diffprivlib → IPFS (private swarm) | ✅ |
| Containerized node | Docker `grower-node` | ✅ |
| Federated learning server | Flower 1.8.0 | ✅ |
| Federated client (PyTorch) | Flower + diffprivlib Laplace noise | ✅ |
| Synthetic data generators | Cannabis / mushroom sensor simulation | ✅ |
| Privacy stack | IBM diffprivlib, scikit-learn 1.6.0 | ✅ |

---

## 📁 Repository Structure

```
AgNetworking/
├── README.md                    # This file
├── SERVER-FOUNDATION.md         # Ubuntu + IPFS + Docker setup
├── privacy-stack.md             # Differential privacy and IBM tools
├── ecosystem.md                 # System diagram (if present)
├── logs/
│   └── setup-log.md             # Record of pip installs
└── scripts/
    └── pip-log.sh               # Logging wrapper for pip
```

Your working code lives in `~/AgTechAI/`:
```
~/AgTechAI/
├── venv/                        # Python 3.11 virtual environment
├── server.py                    # Flower server (aggregator)
├── client.py                    # Flower client (grower node)
└── synthetic_node.py            # (optional) standalone data generator
```

And the grower node container:
```
~/grower-node/
├── Dockerfile
├── encrypt_and_send.py          # CSV → diffprivlib → IPFS
├── requirements.txt
└── sensor_data/                 # Drop CSVs here for processing
```

---

## 🚀 How to Run Everything (from scratch)

### 1. Activate the environment
```bash
cd ~/AgTechAI
source venv/bin/activate
```

### 2. Start the Flower server (Terminal 1)
```bash
python server.py
```
You’ll see: `INFO : Starting Flower server, config: num_rounds=5`

### 3. Start synthetic clients (Terminals 2 and 3)

**Cannabis node:**
```bash
cd ~/AgTechAI && source venv/bin/activate
python client.py --mode synth --type cannabis --node-id node1
```

**Mushroom node:**
```bash
cd ~/AgTechAI && source venv/bin/activate
python client.py --mode synth --type mushroom --node-id node2
```

Watch the server aggregate results. After 5 rounds it shuts down gracefully.

### 4. Use real grow data
Drop a CSV with columns:  
`temperature, humidity, co2, vpd, ec, ph, contaminated`  
into `~/grower-node/sensor_data/` and run:
```bash
python client.py --mode real --node-id my_grow
```

---

## 🔐 Privacy Mechanisms

- **Diffprivlib Laplace mechanism** – adds calibrated noise to gradients (ε = 0.5 default)
- **No raw data leaves the node** – only model updates
- **IPFS private swarm** – encrypted, permissioned storage (optional for parameter exchange)

---

## 🧪 Synthetic Data Details

The `--mode synth` generates realistic sensor logs:

| Crop | Temp (°C) | Humidity (%) | CO₂ (ppm) | VPD (kPa) | EC (µS/cm) | pH | Contamination probability |
|------|-----------|--------------|-----------|-----------|------------|-----|---------------------------|
| Cannabis | 23.5 ± 0.5 | 78 ± 3 | 420 ± 15 | 0.6 ± 0.1 | 1000 ± 100 | 6.2 ± 0.2 | 1% → 5% after day 7 |
| Mushroom | 20 ± 1 | 88 ± 3 | 800 ± 100 | 0.3 ± 0.1 | 500 ± 50 | 6.0 ± 0.3 | 2% + 1%/day after day 7 |

These patterns let you test federated learning before real data arrives.

---

## 📦 Key Dependencies (pinned versions)

- Python 3.11 (not 3.14 – protobuf incompatibility)
- `torch` 2.12.0+cpu
- `flwr` 1.8.0
- `diffprivlib` 0.6.5
- `scikit-learn` 1.6.0 (not 1.9+)
- `pandas`, `numpy`, `joblib`

Install all with:
```bash
pip install torch pandas numpy flwr==1.8.0 diffprivlib scikit-learn==1.6.0 joblib
```

---

## 🧰 Troubleshooting

| Error | Solution |
|-------|----------|
| `ModuleNotFoundError: No module named 'torch'` | `pip install torch --index-url https://download.pytorch.org/whl/cpu` |
| `cannot import name 'LaplaceMechanism'` | Use `Laplace` instead – run `sed -i 's/LaplaceMechanism/Laplace/g' client.py` |
| `ImportError: cannot import name 'DOUBLE' from 'sklearn.tree._tree'` | `pip install scikit-learn==1.6.0` |
| `Disk quota exceeded` | Clean `~/.cache/pip`, remove old ISOs, or move project to `/opt` |
| Flower server shows `0 results and 2 failures` | Check client terminals for errors (usually import or column mismatch) |

---

## 🌱 Next Steps (Roadmap)

- [ ] Train on **real** grow data (your manual CSV logs)
- [ ] Add **second physical node** (Rocky Linux USB) pointing to `--server 192.168.1.139:8081`
- [ ] Replace direct TCP with **IPFS** for parameter exchange
- [ ] Implement **DID + ZKP** for node identity
- [ ] Add **homomorphic encryption** (future)
- [ ] Expand to **beehives, hydroponics, other crops**

---

## 📚 Related Documents

- [SERVER-FOUNDATION.md](./SERVER-FOUNDATION.md) – Ubuntu, IPFS, Docker setup
- [privacy-stack.md](./privacy-stack.md) – Differential privacy theory and IBM tools

---

## 🧬 Mycelial Metaphor

Just as mycelium connects plants underground, sharing nutrients without exposing individual roots –  
this network connects growers, sharing model intelligence without exposing raw data.  
Each node is independent. The network is stronger together.

---

**You are the first node. The network grows with you.** 🍄


---

## 🍄 Mycelial Network Architecture (2026)

The project now includes a fully autonomous, self‑maintaining AI agent system. It consists of:

- **File System** (`~/mycelial/`) – source of truth, hooks, state, logs.
- **Agents** – Boss, Coding, Security, Data Gatherer, Agriculture.
- **Hooks** – validation checkpoints for every action (pre/post edit, commit, deploy, scan, quarantine, eliminate).
- **Automation** – cron‑triggered update scanning, gravity updates, log monitoring.
- **Integration** – Pi‑hole DNS blocking, Docker container management, system updates.

See `mycelial-snapshot/` for the complete blueprint.

