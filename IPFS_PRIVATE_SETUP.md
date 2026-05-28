# IPFS Private Network Setup for Empirical Connections

## Date
May 27, 2026

## Purpose
Create a private IPFS swarm for growers to exchange encrypted sensor data without relying on public nodes or cloud services.

## Steps Performed

### 1. Install IPFS (Kubo)
```bash
cd /tmp
wget "https://github.com/ipfs/kubo/releases/latest/download/kubo_$(curl -s https://api.github.com/repos/ipfs/kubo/releases/latest | grep -oP '"tag_name": "\K[^"]+'")_linux-amd64.tar.gz"
tar -xzf kubo_*_linux-amd64.tar.gz
cd kubo
sudo bash install.sh
```

### 2. Initialize and configure
```bash
ipfs init
ipfs config --json Addresses.Gateway '"/ip4/127.0.0.1/tcp/9090"'   # avoid Pi‑hole port 8080
```

### 3. Create a private swarm key
```bash
openssl rand -base64 32 > ~/.ipfs/swarm.key
chmod 600 ~/.ipfs/swarm.key
```

### 4. Remove public bootstrap nodes
```bash
ipfs bootstrap rm --all
```

### 5. Disable unnecessary services (for private network)
```bash
ipfs config --bool Discovery.MDNS.Enabled false
```

### 6. Create a systemd service for IPFS
File: `/etc/systemd/system/ipfs.service`
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

### 7. Start and enable the service
```bash
sudo systemctl daemon-reload
sudo systemctl enable ipfs
sudo systemctl start ipfs
```

## Troubleshooting

If the service fails to start with `exit-code` and `start request repeated too quickly`:
- Check manual daemon: `ipfs daemon` (shows actual error)
- Common fixes:
  - Remove stale lock: `rm -f ~/.ipfs/repo.lock`
  - Change ports if occupied: modify `Addresses.Swarm`, `Addresses.API`, `Addresses.Gateway` via `ipfs config --json`
  - Ensure no other IPFS process is running: `pkill ipfs`
After fixing, restart service: `sudo systemctl restart ipfs`

## Encryption & Upload Script

Location: `~/AgTechAI/encrypt_and_send.py`

Purpose: Watch a directory for new CSV sensor files, apply differential privacy (via diffprivlib), and upload the encrypted CSV to the private IPFS swarm.

Key lines:
```python
DATA_DIR = "/home/anureyki/AgTechAI/sensor_data"
client = ipfshttpclient.connect('/ip4/127.0.0.1/tcp/5001')
cid = client.add_bytes(encrypted_data)
```

Usage:
```bash
cd ~/AgTechAI
source venv/bin/activate
python encrypt_and_send.py
```
## Testing Workflow
- **Ubuntu (main server)**: rapid prototyping, break/fix, daily development.
- **Rocky Linux 10 (USB live with persistence)**: production‑validation before any deploy to a permanent Rocky system.
  
## Current Status

- IPFS daemon runs as a systemd service (private swarm).
- Gateway listens on `9090`, API on `5001`, Swarm on `4001`.
- Python virtual environment `~/AgTechAI/venv` contains `ipfshttpclient`, `pandas`, `diffprivlib`, etc.
- Test CSV uploaded successfully (CID obtained).
- Next step: Have the AI retrieve CIDs and train on decrypted data.

## Related Documents

- [Server Foundation](SERVER-FOUNDATION.md)
- [Privacy Stack](privacy-stack.md)
- [Ecosystem Overview](ecosystem-overview.md)

## Notes

- The private swarm key (`~/.ipfs/swarm.key`) must be shared with any other node (e.g., grower's node) for them to join the network.
- All data added to IPFS is automatically chunked and distributed only among peers that possess the same swarm key.

## Private Network Troubleshooting & Final Configuration

### Problem
After creating `swarm.key`, IPFS failed to start with errors:
- `expected file header /key/swarm/psk/1.0.0/`
- `AutoConf cannot use default mainnet URL on a private network`
- `Routing.DelegateedRouters contains auto but AutoConf.Enabled=false`
- `AutoTLS not compatible with private network`

### Root Cause
- `swarm.key` was missing the required header line.
- Default routing and AutoTLS settings attempt public internet connections, which fail on a private network.

### Fix Commands
```bash
# 1. Create properly formatted swarm.key
cp ~/.ipfs/swarm.key ~/.ipfs/swarm.key.bak
echo "/key/swarm/psk/1.0.0/" > ~/.ipfs/swarm.key
echo "/base64/" >> ~/.ipfs/swarm.key
openssl rand -base64 32 >> ~/.ipfs/swarm.key
chmod 600 ~/.ipfs/swarm.key

# 2. Disable AutoTLS (incompatible with private network)
ipfs config --bool AutoTLS.Enabled false

# 3. Set routing to explicit DHT (not auto)
ipfs config Routing.Type dht

# 4. Clear delegated routers and IPNS publishers
ipfs config --json Routing.DelegatedRouters '[]'
ipfs config --json Ipns.DelegatedPublishers '[]'

# 5. Restart and verify
sudo systemctl restart ipfs
sudo systemctl status ipfs
```

### Verification
```bash
sudo journalctl -u ipfs -n 20 --no-pager | grep -i error
# Should return no errors. Final line should contain "Daemon is ready".
```

### Current Status
- ✅ IPFS daemon runs without errors on private network.
- ✅ `swarm.key` is correctly formatted with header.
- ✅ AutoTLS disabled, routing forced to DHT, delegated routers cleared.
- ✅ Gateway on port 9090, API on 5001.
