#!/usr/bin/env bash

cleanup_game() {
    echo "Cleaning up the environment..."

    rm -rf "$SPACESHIP_DIR"
    rm -f "$TIME_UP_FILE"
    rm -f "$EMERGENCY_REPAIR_GUIDE"
    rm -f "repair_protocol.sh" || true

    if [ -f ship_sync.pid ]; then
        sync_pid=$(cat ship_sync.pid)
        
        # Kill the specific process and suppress the "Killed" message
        kill "$sync_pid" > /dev/null 2>&1
        wait "$sync_pid" 2>/dev/null
        
        rm ship_sync.pid
    fi

    pkill -9 -f ship_sync.sh 2>/dev/null || true

    echo "Cleanup complete"  
}