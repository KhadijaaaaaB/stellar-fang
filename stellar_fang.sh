#!/usr/bin/env bash

# --- Main Game Script: stellar_fang.sh ---

# Source the configuration and helper scripts
source setup.sh
source timer.sh
source cleanup.sh

#default difficulty 
DIFFICULTY="normal"

# This loop reads command-line arguments (--level)
while [[ $# -gt 0 ]]; do #as long as there are command-line arguments to process
    key="$1" #1st argument
    case $key in
        --level)
        DIFFICULTY="$2" #argument following the first, the value for level 
        shift # past argument
        shift # past value
        ;;
        *)    # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Export the chosen difficulty so timer.sh can use it
export DIFFICULTY
echo $$ > sf.pid
# --- Main Game ---
clear

if [ -f timer.pid ]; then
  kill $(cat timer.pid) 2>/dev/null || true
  rm -f timer.pid
fi

setup_game 
start_timer 

# --- Introduction ---
echo "=========================================="
echo "      Welcome to the Stellar Fang         "
echo "=========================================="
echo "ALERT: A system is offline! You have 20 minutes to identify and restore it."
echo "You may enter the main hub of the ship: $SPACESHIP_DIR"
echo "Type 'help' to see authorized commands."
echo ""


# Signal handler for TIME UP
handle_time_up() {
    echo -e "\n\n*** TIME'S UP! ***"
    echo "The ship's systems have failed completely. Mission failed."
    cleanup_game
    exit 0
}

# Signal handler for WIN
handle_win() {
    echo -e "\n\n*** CONGRATULATIONS! ***"
    echo "You successfully repaired the $DAMAGED_PART. The ship is safe!"
    cleanup_game
    exit 0
}

# Signal handler for BAILOUT
handle_bailout() {
    echo -e "\n\n*** BAIL-OUT SUCCESSFUL ***"
    echo "You escaped the ship, but the Stellar Fang is lost. You survived, but the mission failed."
    cleanup_game
    exit 0
}

# Set traps for user-defined signals
trap 'handle_time_up' USR1
trap 'handle_win' USR2
trap 'handle_bailout' TERM

# --- Main Game Loop ---
while true; do
    # Read player command
    read -t 200 -p $'\033[32m> \033[0m' cmd args
    if [[ $? -ne 0 ]]; then
      # No input received, loop continues, allows signal handling
      continue
    fi

    case "$cmd" in
        ls|cd|cat|grep|find|mkdir|mv|chm|ps)
            # Execute the command safely
            $cmd $args
            ;;
        help)
            echo -e "\033[36mShowing help information...\033[0m"
            cat docs/help.txt
            ;;
        exit)
            echo "Aborting mission... Goodbye."
            break
            ;;
        kill)
            kill $args 
            ;;
        time)
            CURRENT_TIME=$(date +%s)
            ELAPSED_TIME=$((CURRENT_TIME - START_TIME))
            TIME_LEFT=$((GAME_DURATION - ELAPSED_TIME))

            minutes=$((TIME_LEFT / 60))
            seconds=$((TIME_LEFT % 60))
            TIME="${minutes}m ${seconds}s"

            echo -e "\033[33mYou still have $TIME left\033[0m"
            ;;
        *)
            echo "Error: Command '$cmd' not recognized. Type 'help'."
            ;;
    esac
done

# --- Cleanup ---
cleanup_game 
pkill -9 -f "stellar_fang.sh" > /dev/null 2>&1 || true
