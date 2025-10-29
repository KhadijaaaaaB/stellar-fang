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

    echo ">>> Loading Spaceship..."

    # 1. Create spaceship folder
    mkdir "$SPACESHIP_DIR"

    #Create Emergency System Repair Guide
    touch "$SPACESHIP_DIR/EMERGENCY_REPAIR_GUIDE" 
    echo "If parts are broken, you can find replacement in storage."> "$SPACESHIP_DIR/EMERGENCY_REPAIR_GUIDE" 
    echo "You need to move the needed parts to the location of the broken part of the spaceship." >> "$SPACESHIP_DIR/EMERGENCY_REPAIR_GUIDE" 
    echo "The replacement parts shall be stored in a directory, called for_repair" >> "$SPACESHIP_DIR/EMERGENCY_REPAIR_GUIDE" 


    # 2. Build the ship's directory structure
    for category in "${SHIP_CATEGORIES[@]}"; do
        mkdir -p "$SPACESHIP_DIR/$category"
    done

    for part in "${ALL_SHIP_PARTS[@]}"; do
        mkdir -p "$SPACESHIP_DIR/$part"
    done

    mkdir -p "$SPACESHIP_DIR/storage/archives"

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

    # 3. Randomly select the damaged part for this session
    DAMAGED_PART=${POSSIBLE_DAMAGED_PARTS[$((RANDOM % ${#POSSIBLE_DAMAGED_PARTS[@]}))]}
    export DAMAGED_PART # Make it available to the main script

    # 4. Create status files for all critical systems
    #    This loop creates a "status.txt" in each of the four possible failure points.
    for part in "${POSSIBLE_DAMAGED_PARTS[@]}"; do
        # Check if the current part in the loop is the one we selected as damaged
        echo "System Status: OK. All systems nominal." > "$SPACESHIP_DIR/$part/status.txt"
        # This is the broken part. Create the error message and the first clue.
        
        STATUS_FILE="$SPACESHIP_DIR/$DAMAGED_PART/status.txt"
        echo "ALERT: Critical failure detected in '$DAMAGED_PART'." > "$STATUS_FILE"
        echo "|| /!\ Please refer to the Emergency System Repair Guide /!\ || " >> "$STATUS_FILE"
        echo "" >> "$STATUS_FILE"
        echo "Parts requiring replacement:" >> "$STATUS_FILE"

        # Determine which part failed and list missing components
        case "$part" in
            "Orbiter/Nose_Reaction_Control_System")
                for file in "${RCS_repair[@]}"; do
                    echo "- $file" >> "$STATUS_FILE"
                done
                ;;
            "Main_Engine")
                for file in "${MainEngine_repair[@]}"; do
                    echo "- $file" >> "$STATUS_FILE"
                done
                ;;
            "External_Tank/Liquid_Oxygen_Tank")
                for file in "${ExternalTank_repair[@]}"; do
                    echo "- $file" >> "$STATUS_FILE"
                done
                ;;
            "OMS")
                for file in "${OMS_repair[@]}"; do
                    echo "- $file" >> "$STATUS_FILE"
                done
                ;;
        esac

    done

    # Clue #2: The manifest file leading to the repair kit
    echo "Repair kit location logged as: $SPACESHIP_DIR/storage/hidden_depot" > "$SPACESHIP_DIR/storage/archives/manifesto.log"

    # 5. Create the repair kit and the "virus" puzzle
    # The final script the player must run to win
    echo "#!/bin/bash" > "$SPACESHIP_DIR/storage/hidden_depot/repair_protocol.sh"
    echo "echo 'Repair sequence initiated... Success!'" >> "$SPACESHIP_DIR/storage/hidden_depot/repair_protocol.sh"
    echo "touch \"$SPACESHIP_DIR/$DAMAGED_PART/repaired\"" >> "$SPACESHIP_DIR/storage/hidden_depot/repair_protocol.sh"
    # The "virus" simulation: make the script inaccessible
    chmod 000 "$SPACESHIP_DIR/storage/hidden_depot/repair_protocol.sh"

    # 6. Create the files for the "Bail-Out" alternate ending
    # The instruction file for bailing out
    echo "Bail-out procedure: To jettison the hatch, you must first disable the safety locks." > "$SPACESHIP_DIR/Orbiter/Safety_Hatches/bailout_protocol.txt"
    echo "To do this, make 'initiate_bailout.sh' executable and run it." >> "$SPACESHIP_DIR/Orbiter/Safety_Hatches/bailout_protocol.txt"

    # The bail-out script itself, which is initially locked
    echo "#!/bin/bash" > "$SPACESHIP_DIR/Orbiter/Safety_Hatches/initiate_bailout.sh"
    echo "echo 'Safety locks disengaged. Hatch jettisoned. You are clear...'" >> "$SPACESHIP_DIR/Orbiter/Safety_Hatches/initiate_bailout.sh"
    echo "touch \"$SPACESHIP_DIR/Orbiter/Safety_Hatches/bailed_out\"" >> "$SPACESHIP_DIR/Orbiter/Safety_Hatches/initiate_bailout.sh"
    # Lock the bail-out script
    chmod 000 "$SPACESHIP_DIR/Orbiter/Safety_Hatches/initiate_bailout.sh"

    # 7. Set the player's starting location

    echo ">>> Spaceship ready."

}

setup_game
