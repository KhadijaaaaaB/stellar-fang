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


# --- Main Game ---
clear
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


# --- Main Game Loop ---
while true; do
    # Check for loss condition (timer expired)
    if [ -f "$TIME_UP_FILE" ]; then
        echo -e "\n\n*** TIME'S UP! ***"
        echo "The ship's systems have failed completely. Mission failed."
        break
    fi
    
    # Check for win condition (part repaired)
    if [ -f "$SPACESHIP_DIR/$DAMAGED_PART/repaired" ]; then
        echo -e "\n\n*** CONGRATULATIONS! ***"
        echo "You successfully repaired the $DAMAGED_PART. The ship is safe!"
        break
    fi
    
    # Check for bailout win condition
    if [ -f "$SPACESHIP_DIR/Orbiter/Safety_Hatches/bailed_out" ]; then
        echo -e "\n\n*** BAIL-OUT SUCCESSFUL ***"
        echo "You escaped the ship, but the Stellar Fang is lost. You survived, but the mission failed."
        break
    fi

    # Read player command
    read -p "$PROMPT" cmd args

    case "$cmd" in
        ls|cd|cat|grep|find|mkdir|mv|chm|ps|kill)
            # Execute the command safely
            $cmd $args
            ;;
        help)
            cat docs/help.txt
            ;;
        exit)
            echo "Aborting mission... Goodbye."
            break
            ;;
        *)
            echo "Error: Command '$cmd' not recognized. Type 'help'."
            ;;
    esac
done

# --- Cleanup ---
cleanup_game # This function is in cleanup.sh
