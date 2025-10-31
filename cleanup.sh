#!/usr/bin/env bash

cleanup_game() {
    echo "Cleaning up the environment..."

    rm -rf "$SPACESHIP_DIR"
    rm -f "$TIME_UP_FILE"
    rm -f "$EMERGENCY_REPAIR_GUIDE"
    pkill -9 -f "ship_sync.sh" > /dev/null 2>&1 || true

    echo "Cleanup complete"  
}