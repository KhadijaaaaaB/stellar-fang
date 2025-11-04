#!/usr/bin/env bash

# --- timer.sh for Stellar Fang (with difficulty) ---

# This script sets and starts the game's countdown timer
# based on the difficulty level chosen by the player.

rm -f "$TIME_UP_FILE"

# --- Timer Function ---
start_timer() {
    # Determine the game duration based on the exported DIFFICULTY variable
    case "$DIFFICULTY" in
        "easy")
            GAME_DURATION=1800 # 30 minutes
            echo "Difficulty set to Easy. You have 30 minutes."
            ;;
        "hard")
            GAME_DURATION=600  # 10 minutes
            echo "Difficulty set to Hard. You have 10 minutes. Good luck."
            ;;
        *) # Default to normal for any other input
            GAME_DURATION=1200 # 20 minutes
            echo "Difficulty set to Normal. You have 20 minutes."
            ;;
    esac

    # Record the start time (
    START_TIME=$(date +%s)
    export START_TIME
    
    # Run the timer in the background. When it finishes, it creates the time-up file.
    (sleep $GAME_DURATION &
    echo $! > pids/timer.pid 
    wait $! 
    touch "$TIME_UP_FILE" && kill -USR1 "$(cat pids/sf.pid)") &   
}
