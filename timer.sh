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
            GAME_DURATION=5 # 20 minutes
            echo "Difficulty set to Normal. You have 20 minutes."
            ;;
    esac

    # Record the start time (
    START_TIME=$(date +%s)
    export START_TIME

    if [ ! -z "$TIMER_PID" ] && kill -0 "$TIMER_PID" 2>/dev/null; then
        kill "$TIMER_PID"
    fi
    
    # Run the timer in the background. When it finishes, it creates the time-up file.
    (sleep $GAME_DURATION && touch "$TIME_UP_FILE" && kill -USR1 "$$") &   
    
    # Export the timer's Process ID so the main script can stop it if needed.
    TIMER_PID=$!
    export TIMER_PID
    echo $TIMER_PID > timer.pid
}
