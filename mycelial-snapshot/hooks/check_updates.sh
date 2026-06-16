#!/bin/bash
# check_updates.sh – Scan for system, blocklist, and software updates
# Usage: check_updates.sh [type]

TYPE="${1:-all}"
OUTPUT_DIR="$HOME/mycelial/state/updates"
mkdir -p "$OUTPUT_DIR"

# --- 1. Check Pi‑hole Gravity updates ---
check_gravity() {
    if docker ps --filter "name=pihole-unbound" --filter "status=running" --format "{{.Names}}" | grep -q "pihole-unbound"; then
        # Get the number of domains currently blocked
        CURRENT_COUNT=$(docker exec pihole-unbound pihole -c -j 2>/dev/null | grep -o '"domains_being_blocked":[0-9]*' | cut -d':' -f2)
        
        # Get the last update timestamp from the gravity database (if available)
        if [[ -f "/opt/pi-hole/etc-pihole/gravity.db" ]]; then
            LAST_UPDATE=$(stat -c %Y "/opt/pi-hole/etc-pihole/gravity.db" 2>/dev/null || stat -f %m "/opt/pi-hole/etc-pihole/gravity.db" 2>/dev/null)
            LAST_UPDATE_HUMAN=$(date -d "@$LAST_UPDATE" "+%Y-%m-%d %H:%M:%S" 2>/dev/null || echo "unknown")
        else
            LAST_UPDATE_HUMAN="unknown"
        fi
        
        printf "PIHOLE_GRAVITY|count=%s|last_update=%s\n" "$CURRENT_COUNT" "$LAST_UPDATE_HUMAN" > "$OUTPUT_DIR/pihole_gravity.txt"
        printf "OK: Pi‑hole gravity status recorded.\n"
    else
        printf "WARNING: Pi‑hole container not running.\n"
    fi
}

# --- 2. Check for apt updates (system packages) ---
check_apt() {
    sudo apt update -qq 2>/dev/null
    UPDATES=$(apt list --upgradable 2>/dev/null | grep -c "upgradable")
    printf "APT|updates=%s\n" "$UPDATES" > "$OUTPUT_DIR/apt.txt"
    printf "OK: Apt updates checked: %s available.\n" "$UPDATES"
}

# --- 3. Check for pip updates (Python packages) ---
check_pip() {
    if command -v pip3 &> /dev/null; then
        OUTDATED=$(pip3 list --outdated --format=json 2>/dev/null | grep -c '"name"')
        printf "PIP|outdated=%s\n" "$OUTDATED" > "$OUTPUT_DIR/pip.txt"
        printf "OK: Pip updates checked: %s outdated packages.\n" "$OUTDATED"
    else
        printf "WARNING: pip3 not found.\n"
    fi
}

# --- 4. Check for Docker image updates ---
check_docker() {
    if command -v docker &> /dev/null; then
        # Check if pihole-unbound image has an update
        if docker ps --filter "name=pihole-unbound" --format "{{.Image}}" | grep -q .; then
            CURRENT_IMAGE=$(docker ps --filter "name=pihole-unbound" --format "{{.Image}}")
            docker pull "$CURRENT_IMAGE" --quiet 2>/dev/null
            printf "DOCKER|image=%s\n" "$CURRENT_IMAGE" > "$OUTPUT_DIR/docker.txt"
            printf "OK: Docker image %s checked for updates.\n" "$CURRENT_IMAGE"
        fi
    fi
}

# --- 5. Check for new external data sources (e.g., USDA, weather) ---
check_external_data() {
    # Example: Check if a known API has new data (placeholder)
    # In practice, you'd call an API and check timestamps or version numbers
    printf "EXTERNAL|last_check=%s|status=pending\n" "$(date -Iseconds)" > "$OUTPUT_DIR/external.txt"
    printf "OK: External data check recorded.\n"
}

# --- Main dispatch ---
case "$TYPE" in
    gravity)
        check_gravity
        ;;
    apt)
        check_apt
        ;;
    pip)
        check_pip
        ;;
    docker)
        check_docker
        ;;
    external)
        check_external_data
        ;;
    all)
        check_gravity
        check_apt
        check_pip
        check_docker
        check_external_data
        ;;
    *)
        printf "ERROR: Unknown update type: %s\n" "$TYPE"
        exit 1
        ;;
esac

# Write a summary file
cat > "$OUTPUT_DIR/summary.txt" << EOJ
Updates checked at $(date -Iseconds)

$(cat "$OUTPUT_DIR"/*.txt 2>/dev/null)
EOJ

exit 0
