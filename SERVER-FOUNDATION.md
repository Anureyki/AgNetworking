# Server Foundation: AgTech AI + IPFS + Privacy Stack

This document records the core setup of the Ubuntu server that runs the Empirical Connections infrastructure: Python virtual environment, privacy‑preserving AI libraries, IPFS node, automation tools, cron‑based sync, and the grower node Docker container.

## 1. Python Virtual Environment (AgTechAI)

All AI and data processing happens inside a dedicated virtual environment to avoid conflicts with system Python.

```bash
mkdir -p ~/AgTechAI
cd ~/AgTechAI
python3 -m venv venv
source venv/bin/activate
```

## 2. Core Python Libraries

Installed inside the virtual environment:

```bash
pip install diffprivlib               # IBM differential privacy
pip install adversarial-robustness-toolbox   # ART – model defense
pip install pandas                    # CSV data manipulation
pip install requests                  # HTTP calls to IPFS API (for container)
```

Verification commands:

```bash
python -c "import diffprivlib; print('Diffprivlib ready')"
python -c "from art.attacks import evasion; print('ART evasion module loaded')"
python -c "import pandas as pd; print(pd.__version__)"
python -c "import requests; print('Requests ready')"
```

## 3. IPFS Node (Kubo)

### Install Kubo

```bash
cd /tmp
wget "https://github.com/ipfs/kubo/releases/latest/download/kubo_$(curl -s https://api.github.com/repos/ipfs/kubo/releases/latest | grep -oP '"tag_name": "\K[^"]+'")_linux-amd64.tar.gz"
tar -xzf kubo_*_linux-amd64.tar.gz
cd kubo
sudo bash install.sh
```

### Initialize and configure

```bash
ipfs init
ipfs config --json Addresses.Gateway '"/ip4/127.0.0.1/tcp/9090"'   # avoid Pi‑hole port 8080
```

### Run as systemd service

Create `/etc/systemd/system/ipfs.service`:

```ini
[Unit]
Description=IPFS Daemon
After=network.target

[Service]
Type=simple
User=anureyki
ExecStart=/usr/local/bin/ipfs daemon
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Enable and start:

```bash
sudo systemctl daemon-reload
sudo systemctl enable ipfs
sudo systemctl start ipfs
sudo systemctl status ipfs
```

### Test IPFS

```bash
echo "Hello from Empirical Connections" > test.txt
ipfs add test.txt
curl http://127.0.0.1:9090/ipfs/Qm...   # use the CID from the add command
```

## 4. Ansible (Configuration Management)

Installed for repeatable server setup.

```bash
sudo apt update && sudo apt install ansible -y
```

Test playbook (`test.yml`):

```yaml
---
- name: Test Ansible
  hosts: localhost
  tasks:
    - name: Print a message
      debug:
        msg: 'Ansible is working!'
```

Run:

```bash
ansible-playbook test.yml --syntax-check
ansible-playbook test.yml
```

## 5. Cron Job for Git Sync

Automatically push/pull the `AgNetworking` repository every 30 minutes.

```bash
crontab -e
```

Add:

```cron
*/30 * * * * cd /home/anureyki/AgNetworking && /usr/bin/git pull origin main --no-edit && /usr/bin/git push origin main >> /home/anureyki/agnetwork-sync.log 2>&1
```

## 6. Custom `pip-log` Wrapper

To automatically log every `pip install` inside the virtual environment to `AgNetworking/logs/setup-log.md`.

Script `~/AgNetworking/scripts/pip-log.sh`:

```bash
#!/bin/bash
LOG_FILE="$HOME/AgNetworking/logs/setup-log.md"
pip "$@"
if [[ "$1" == "install" ]]; then
    PACKAGES="${@:2}"
    echo "- $(date): Installed $PACKAGES" >> "$LOG_FILE"
fi
```

Make executable and add to PATH:

```bash
chmod +x ~/AgNetworking/scripts/pip-log.sh
echo 'export PATH="$HOME/AgNetworking/scripts:$PATH"' >> ~/.bashrc
source ~/.bashrc
```

Now `pip-log install <package>` logs automatically.

## 7. Grower Node Docker Container

A containerized version of the encryption and upload script that runs continuously, watching for new CSV files and uploading them to IPFS.

### Directory structure

```bash
mkdir -p ~/grower-node/sensor_data
cd ~/grower-node
```

### Dockerfile

```dockerfile
FROM python:3.11-slim

WORKDIR /app

COPY encrypt_and_send.py .
COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

CMD ["python", "encrypt_and_send.py"]
```

### requirements.txt

```text
pandas
requests
```

### encrypt_and_send.py

```python
#!/usr/bin/env python3
import os
import time
import requests
import pandas as pd

DATA_DIR = "/app/sensor_data"
IPFS_API = "http://127.0.0.1:5001"

def process_csv(file_path):
    df = pd.read_csv(file_path)
    df["'processed_at'] = time.strftime("%Y-%m-%d %H:%M:%S")
    return df.to_csv(index=False)

def upload_to_ipfs(data_string):
    response = requests.post(IPFS_API + "/api/v0/add", files={"'file']: data_string})
    if response.status_code == 200:
        cid = response.json()["'Hash']
        requests.post(IPFS_API + "/api/v0/pin/add", params={"'arg']: cid})
        return cid
    else:
        raise Exception(f"IPFS upload failed: {response.text}")

def main():
    if not os.path.exists(DATA_DIR):
        print(f"Data directory {DATA_DIR} does not exist.")
        return
    for filename in os.listdir(DATA_DIR):
        if filename.endswith("'.csv'") and not filename.endswith("'.processed'):
            full_path = os.path.join(DATA_DIR, filename)
            print(f"Processing {full_path}")
            processed_data = process_csv(full_path)
            cid = upload_to_ipfs(processed_data)
            print(f"Uploaded to IPFS, CID: {cid}")
            os.rename(full_path, full_path + '.processed')

if __name__ == '__main__':
    print("Grower node started. Watching for CSV files...")
    while True:
        main()
        time.sleep(60)
```

### Build and run

```bash
cd ~/grower-node
docker build -t grower-node .
docker run -d --name grower-node --network host -v $(pwd)/sensor_data:/app/sensor_data grower-node
```

### Verify

```bash
docker logs grower-node
```

## 8. Current Status (as of June 2026)

| Component | Status | Notes |
|-----------|--------|-------|
| Python virtual environment | ✅ Running | `~/AgTechAI/venv` |
| Diffprivlib | ✅ Installed | Verified import |
| ART | ✅ Installed | Evasion module works |
| Pandas | ✅ Installed | CSV processing ready |
| Requests | ✅ Installed | HTTP calls for IPFS API |
| IPFS daemon | ✅ Running | systemd service, gateway on 9090 |
| Ansible | ✅ Installed | Test playbook succeeded |
| Cron sync | ✅ Active | Every 30 minutes |
| pip‑log wrapper | ✅ Active | Logs all pip installs |
| Grower node container | ✅ Running | `~/grower-node` with `grower-node` container |

## 9. Related Documents

- [Ecosystem Overview](ecosystem-overview.md)
- [Privacy Stack](privacy-stack.md)
- [Certification Roadmap](cert-roadmap.md)
- [Setup Log](logs/setup-log.md)

## 10. Next Steps

- ~~Write Python script to encrypt CSV and upload to IPFS.~~ (Done)
- Add real encryption (diffprivlib) back to the container.
- Train first privacy‑preserving model.
- Distribute the grower node container to other growers.
- Implement tokenization (after CTDS certification).

---
*This document is part of the AgNetworking repository and will be updated as the infrastructure evolves.*
