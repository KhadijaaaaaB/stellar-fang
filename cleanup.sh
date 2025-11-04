#!/usr/bin/env bash
export end_game=false
cleanup_game() {
    echo "Cleaning up the environment..."

    rm -rf "$SPACESHIP_DIR"
    rm -f "$TIME_UP_FILE"
    rm -f "repair_protocol.sh" || true

    kill $(cat pids/ship_sync.pid) || true
    kill $(cat pids/timer.pid) || true
    rm -r pids || true
 
    pkill -9 -f ship_sync.sh 2>/dev/null || true #to ensure no residue process remains
    echo "Cleanup complete"  
    
    rm -f "repair_protocol.sh" || true #in case it was created after ship_sync.sh ended
    if $end_game; then
      pkill -9 -f "stellar_fang.sh" > /dev/null 2>&1 || true
    fi
}