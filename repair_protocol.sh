#!/usr/bin/env bash

source setup.sh

# Run part check script
./check_parts.sh
result=$?

if [ $result -eq 0 ]; then
    echo "Repair parts validated. Repairing spaceship..."

    # Example repair logic: mark as repaired by touching a file
    touch "$SPACESHIP_DIR/$DAMAGED_PART/repaired"

    # Send USR2 (win) signal to main game script
    kill -USR2 "$(cat docs/sf.pid)"
else    
    echo "Repair parts missing or invalid. Cannot proceed with repair."
    exit 1
fi
