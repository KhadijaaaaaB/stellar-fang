#!/usr/bin/env bash

cleanup_game() {
    echo "Cleaning up the environment..."

    rm -rf "$SPACESHIP_DIR"
    rm -f "$TIME_UP_FILE"

    echo "Cleanup complete"  
}