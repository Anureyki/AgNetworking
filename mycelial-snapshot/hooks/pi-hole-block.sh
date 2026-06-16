#!/bin/bash
# pi-hole-block.sh – Add domain to Pi‑hole blocklist (Docker-aware)
# Usage: pi-hole-block.sh <domain> [reason]

DOMAIN="$1"
REASON="${2:-No reason provided}"

if [[ -z "$DOMAIN" ]]; then
    printf "ERROR: No domain specified.\n"
    exit 1
fi

# Check if Pi‑hole container is running
if ! docker ps --filter "name=pihole-unbound" --filter "status=running" --format "{{.Names}}" | grep -q "pihole-unbound"; then
    printf "ERROR: Pi‑hole container 'pihole-unbound' is not running.\n"
    exit 1
fi

# Use Pi‑hole API (assuming port 8080 mapped to host)
PIHOLE_URL="http://127.0.0.1:8080"
PIHOLE_API_TOKEN="${PIHOLE_API_TOKEN:-}"  # Set this environment variable or replace below

# If no token is set, try to fetch it from the container (requires docker exec)
if [[ -z "$PIHOLE_API_TOKEN" ]]; then
    # Try to get the API token from the container's setupVars.conf
    PIHOLE_API_TOKEN=$(docker exec pihole-unbound grep -oP 'WEBPASSWORD=\K.*' /etc/pihole/setupVars.conf 2>/dev/null)
    if [[ -z "$PIHOLE_API_TOKEN" ]]; then
        printf "ERROR: Could not retrieve Pi‑hole API token. Set PIHOLE_API_TOKEN environment variable.\n"
        exit 1
    fi
fi

# Check if domain is already in blocklist (via container)
if docker exec pihole-unbound grep -q "^$DOMAIN$" /etc/pihole/blacklist.txt 2>/dev/null; then
    printf "WARNING: Domain %s already blocked.\n" "$DOMAIN"
    exit 0
fi

# Add domain via API
RESPONSE=$(curl -s -X POST "$PIHOLE_URL/admin/api.php?add=blacklist" \
    -d "domain=$DOMAIN" \
    -d "token=$PIHOLE_API_TOKEN")

# Check response
if echo "$RESPONSE" | grep -q '"success":"true"'; then
    printf "OK: Domain %s added to Pi‑hole blocklist.\n" "$DOMAIN"
    printf "$(date -Iseconds) | security_agent | PI_HOLE_BLOCK | %s | %s\n" "$DOMAIN" "$REASON" >> ~/mycelial/logs/audit.log
    exit 0
else
    printf "ERROR: Failed to add domain %s. Response: %s\n" "$DOMAIN" "$RESPONSE"
    exit 1
fi
