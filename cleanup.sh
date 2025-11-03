#!/usr/bin/env bash

cleanup_game() {
    echo "Cleaning up the environment..."

    rm -rf "$SPACESHIP_DIR"
    rm -f "$TIME_UP_FILE"
    rm -f "$EMERGENCY_REPAIR_GUIDE"
    rm -f "repair_protocol.sh" || true

    if [ -f docs/ship_sync.pid ]; then       
        # Kill the specific process and suppress the "Killed" message
        kill $(cat docs/ship_sync.pid) > /dev/null 2>&1 || true
        rm -f docs/ship_sync.pid
    fi

    if [ -f docs/timer.pid ]; then
      kill $(cat docs/timer.pid) 2>/dev/null || true
      rm -f docs/timer.pid
    fi

    pkill -9 -f ship_sync.sh 2>/dev/null || true

    echo "Cleanup complete"  
}