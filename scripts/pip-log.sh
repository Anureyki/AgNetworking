#!/bin/bash
# Wrapper for pip that logs installations to AgNetworking logs

LOG_FILE="$HOME/AgNetworking/logs/setup-log.md"

# Run the actual pip command with all arguments
pip "$@"

# If the command was 'install', log it
if [[ "$1" == "install" ]]; then
    PACKAGES="${@:2}"
    echo "- $(date): Installed $PACKAGES" >> "$LOG_FILE"
    echo "  Logged to $LOG_FILE"
fi
