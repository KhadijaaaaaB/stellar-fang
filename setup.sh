#!/usr/bin/env bash

set -e

# --- setup.sh for Stellar Fang ---
# This script builds the game world from scratch for each session.

# --- Game Configuration ---
# Export variables so they can be used by the main script
export SPACESHIP_DIR="stellar_fang_ship"
export TIME_UP_FILE="stellar_fang_time_up"

source cleanup.sh


# The four parts that can be randomly damaged
POSSIBLE_DAMAGED_PARTS=(
    "Orbiter/Nose_Reaction_Control_System"
    "Main_Engine"
    "External_Tank/Liquid_Oxygen_Tank"
    "OMS"
)

# The full directory structure of the ship
SHIP_CATEGORIES=(
    "External_Tank"
    "SRB" #Solid_Rocket_Booster
    "Orbiter"
    "OMS" #Orbital Maneuvering System
    "Main_Engine"
)

ALL_SHIP_PARTS=(
    "External_Tank/Liquid_Oxygen_Tank"
    "External_Tank/Safety_Valve"
    "External_Tank/Liquid_Hydrogen_Tank"
    "SRB/Reusable_Outer_Casing"
    "SRB/Solid_Propellant"
    "Orbiter/Delta_Wing"
    "Orbiter/Safety_Hatches"
    "Orbiter/Nose_Reaction_Control_System"
    "Orbiter/Star_Trackers"
    "Orbiter/Cargo_Bay_Doors"
    "Orbiter/Elevons"
    "Orbiter/Body_Flap"
    "OMS/Booster_Nozzle"
)

# --- Setup Function ---
setup_game() {
    cleanup_game
    mkdir pids 2>/dev/null || true

    # Start the ship synchronization process (virus) in the background
    sh ship_sync.sh &
    sync_pid=$!
    echo $sync_pid > pids/ship_sync.pid
    (
    while ps -p $sync_pid > /dev/null; do #as long as ship_sync.sh is running, sleep
        sleep 1
    done

    # --- This code runs ONLY AFTER ship_sync.sh has been killed ---
    echo -e "..\n\033[1;31mALERT: VIRUS KILLED! The Emergency Repair Protocol is now available.\033[0m"

    # Create and populate the repair_protocol.sh file in the main ship directory
    cat > "$SF_DIR/repair_protocol.sh" << EOF
#!/usr/bin/env bash

source setup.sh

# Run part check script
./check_parts.sh
result=\$?

if [ \$result -eq 0 ]; then
    echo "Repair parts validated. Repairing spaceship..."

    # Example repair logic: mark as repaired by touching a file
    touch "\$SPACESHIP_DIR/\$DAMAGED_PART/repaired"

    # Send USR2 (win) signal to main game script
    kill -USR2 "\$(cat pids/sf.pid)"
else    
    echo "Repair parts missing or invalid. Cannot proceed with repair."
    exit 1
fi

EOF

) &  # '&' runs this entire watcher block in the background.

    echo ">>> Loading Spaceship..."

    ### Create spaceship folder
    mkdir "$SPACESHIP_DIR"

    # Create Emergency System Repair Guide file
    cat > "$SPACESHIP_DIR/EMERGENCY_REPAIR_GUIDE" << EOF 
================= EMERGENCY SYSTEM REPAIR GUIDE =================
Repair Procedure:

    1.  **Locate Replacement Parts:** Find the necessary spare parts for the damaged system. All spares are located in the \`storage\` directory.
    *Note: Each system has its own subdirectory within \`storage\` where its spare parts are stored. It might be helpful to use \`find\` or \`grep\` commands to locate specific files.
    
    2.  **Prepare for Repair:** Move the required spare parts to the repair location. The repair location is a folder named \`for_repair\`, which is inside the directory of the damaged system.
    *Example: If the \`Nose_Reaction_Control_System\` is broken, move its spare parts to the \`stellar_fang_ship/Nose_Reaction_Control_System/for_repair/\` directory.
    
    3.  **Execute Repair Protocol:** Once all parts are in place, run the repair script located in \`repair_protocol.sh\`. This script will initiate the repair process.
    *Note: Ensure you have the necessary permissions to execute the repair script. If you encounter permission issues, you may need to adjust the file permissions using \`chmod\`.
================================================================
EOF

    ### Build the ship's directory structure
    for category in "${SHIP_CATEGORIES[@]}"; do
        mkdir -p "$SPACESHIP_DIR/$category"
    done

    for part in "${ALL_SHIP_PARTS[@]}"; do
        mkdir -p "$SPACESHIP_DIR/$part"
    done

    mkdir -p "$SPACESHIP_DIR/storage/hidden_depot"
    mkdir -p "$SPACESHIP_DIR/storage/avionics/RCSBACKUPMODULES"
    mkdir -p "$SPACESHIP_DIR/storage/propulsion/safemode"
    mkdir -p "$SPACESHIP_DIR/storage/tankmanagement/emergencyvalves"
    mkdir -p "$SPACESHIP_DIR/storage/navdata"

    ## create parts for repair
    # Define repair component lists
    RCS_repair=("rcscontroller.dll" "thrustercalibration.dat" "yawcontrolmodule.sys")
    MainEngine_repair=("enginecontrollerfirmware.bin" "fuelflowtables.xml" "ignitionsequence.sh")
    ExternalTank_repair=("pressuresensordriver.sys" "tankintegritymonitor.cfg" "LOXvalvecontrol.dat")
    OMS_repair=("omstargetingdata.nav" "deorbitburnsequence.script" "enginegimbalconfig.ini")

    # Nose Reaction Control System (RCS) Parts
    touch $SPACESHIP_DIR/storage/avionics/RCSBACKUPMODULES/rcscontroller.dll
    touch $SPACESHIP_DIR/storage/avionics/RCSBACKUPMODULES/thrustercalibration.dat
    touch $SPACESHIP_DIR/storage/avionics/RCSBACKUPMODULES/yawcontrolmodule.sys

    # Main Engine System Parts
    touch $SPACESHIP_DIR/storage/propulsion/safemode/enginecontrollerfirmware.bin
    touch $SPACESHIP_DIR/storage/propulsion/safemode/fuelflowtables.xml
    touch $SPACESHIP_DIR/storage/propulsion/safemode/ignitionsequence.sh

    # External Tank Parts
    touch $SPACESHIP_DIR/storage/tankmanagement/emergencyvalves/pressuresensordriver.sys
    touch $SPACESHIP_DIR/storage/tankmanagement/emergencyvalves/tankintegritymonitor.cfg
    touch $SPACESHIP_DIR/storage/tankmanagement/emergencyvalves/LOXvalvecontrol.dat

    # Orbital Maneuvering System Parts
    touch $SPACESHIP_DIR/storage/navdata/omstargetingdata.nav
    touch $SPACESHIP_DIR/storage/navdata/deorbitburnsequence.script
    touch $SPACESHIP_DIR/storage/navdata/enginegimbalconfig.ini

    ## Randomly select the damaged part for this session
    DAMAGED_PART=${POSSIBLE_DAMAGED_PARTS[$((RANDOM % ${#POSSIBLE_DAMAGED_PARTS[@]}))]}
    export DAMAGED_PART # Make it available to the main script

    ### Create status files for all critical systems
    ## This loop creates a "status.txt" in each of the four possible failure points.
    for part in "${POSSIBLE_DAMAGED_PARTS[@]}"; do
        echo "System Status: OK. All systems nominal." > "$SPACESHIP_DIR/$part/status.txt"
        
        # If this is the damaged part, modify its status file to indicate failure
        DAMAGED_STATUS="$SPACESHIP_DIR/$DAMAGED_PART/status.txt"
        echo "ALERT: Critical failure detected in '$DAMAGED_PART'." > "$DAMAGED_STATUS"
        echo "|| /!\ Please refer to the Emergency System Repair Guide /!\ || " >> "$DAMAGED_STATUS"
        echo "" >> "$DAMAGED_STATUS"
        echo "Parts requiring replacement:" >> "$DAMAGED_STATUS"

        # Determine which part failed and list missing components
        case "$DAMAGED_PART" in
            "Orbiter/Nose_Reaction_Control_System")
                for file in "${RCS_repair[@]}"; do
                    echo "- $file" >> "$DAMAGED_STATUS"
                done
                ;;
            "Main_Engine")
                for file in "${MainEngine_repair[@]}"; do
                    echo "- $file" >> "$DAMAGED_STATUS"
                done
                ;;
            "External_Tank/Liquid_Oxygen_Tank")
                for file in "${ExternalTank_repair[@]}"; do
                    echo "- $file" >> "$DAMAGED_STATUS"
                done
                ;;
            "OMS")
                for file in "${OMS_repair[@]}"; do
                    echo "- $file" >> "$DAMAGED_STATUS"
                done
                ;;
        esac

    done

    ### Create the files for the "Bail-Out" alternate ending
    # The instruction file for bailing out
    echo "Bail-out procedure: To jettison the hatch, you must first disable the safety locks." > "$SPACESHIP_DIR/Orbiter/Safety_Hatches/bailout_protocol.txt"
    echo "To do this, make 'initiate_bailout.sh' executable and run it." >> "$SPACESHIP_DIR/Orbiter/Safety_Hatches/bailout_protocol.txt"

    
    # The bail-out script itself, which sends the SIGINT signal to the main game process
    cat > "$SPACESHIP_DIR/Orbiter/Safety_Hatches/initiate_bailout.sh" << "EOF"
#!/usr/bin/env bash

source stellar_fang.sh

# This script initiates the emergency bail-out sequence.

echo "Disabling safety locks and jettisoning the escape hatch..."
sleep 2

# Find the main game process ID from the sf.pid file
# The 'readlink -f' ensures we find the file even if this script is run from a different directory
pid_file=$SF_DIR/pids/sf.pid

if [ -f "$pid_file" ]; then
    main_pid=$(cat "$pid_file")
    # Send the SIGINT signal to trigger the 'handle_bailout' function in the main game
    kill -SIGINT "$main_pid"
else
    echo "Error: Could not locate the main ship computer (sf.pid). Bailout failed."
fi
EOF

    echo ">>> Spaceship ready."

}
