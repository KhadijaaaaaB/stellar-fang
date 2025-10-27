#!/usr/bin/env bash

cleanup_game() {
    echo "Cleaning up the environment..."

    rm -rf "$SPACESHIP_DIR"
    rm -f "$TIME_UP_FILE"
    rm -f "$EMERGENCY_REPAIR_GUIDE"

    echo "Cleanup complete"  
}