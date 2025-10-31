#!/usr/bin/env bash

source setup.sh

# Ensure these variables are set properly
if [ -z "$DAMAGED_PART" ] || [ -z "$SPACESHIP_DIR" ]; then
  echo "Error: DAMAGED_PART and SPACESHIP_DIR must be set"
  exit 1
fi

REPAIR_DIR="$SPACESHIP_DIR/$DAMAGED_PART/for_repair"

# Define arrays of required repair parts
declare -A repair_parts
repair_parts[RCS_repair]="rcscontroller.dll thrustercalibration.dat yawcontrolmodule.sys"
repair_parts[MainEngine_repair]="enginecontrollerfirmware.bin fuelflowtables.xml ignitionsequence.sh"
repair_parts[ExternalTank_repair]="pressuresensordriver.sys tankintegritymonitor.cfg LOXvalvecontrol.dat"
repair_parts[OMS_repair]="omstargetingdata.nav deorbitburnsequence.script enginegimbalconfig.ini"

# Map damaged part names to repair arrays (adjust keys to your exact damaged part names)
case "$DAMAGED_PART" in
    "Orbiter/Nose_Reaction_Control_System")
        needed_parts=${repair_parts[RCS_repair]}
        ;;
    "Main_Engine")
        needed_parts=${repair_parts[MainEngine_repair]}
        ;;
    "External_Tank/Liquid_Oxygen_Tank")
        needed_parts=${repair_parts[ExternalTank_repair]}
        ;;
    "OMS") # Orbital_Maneuvering_System
        needed_parts=${repair_parts[OMS_repair]}
        ;;
    *)
        echo "Unknown damaged part: $DAMAGED_PART"
        exit 1
        ;;
esac

# Check for each required repair part's presence
missing_parts=()
for part in $needed_parts; do
  if [ ! -f "$REPAIR_DIR/$part" ]; then
    missing_parts+=("$part")
  fi
done

if [ ${#missing_parts[@]} -eq 0 ]; then
  echo "All required repair parts are present."
  exit 0
else
  echo "Missing repair parts:"
  for m in "${missing_parts[@]}"; do
      echo " - $m"
  done
  exit 1
fi
