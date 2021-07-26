#!/bin/bash

# List Startup Items
# Lists the contents of every known startup item directory.

PRINT_SEPARATOR="echo \"----\""
declare -a STARTUP_DIRS=("/Library/LaunchDaemons"
                         "/Library/LaunchAgents"
                         "/System/Library/LaunchAgents"
                         "/System/Library/LaunchDaemons"
                         "~/Library/LaunchAgents"
                         "~/Library/LaunchDaemons"
                         "~/Library/StartupItems"
                         "/Library/Startup Items")

function listDir()
{
  if [ -d "$1" ]; then
    echo "$1:"
    eval $PRINT_SEPARATOR
    ls "$1"
    eval $PRINT_SEPARATOR
  fi
}

for THE_DIR in "${STARTUP_DIRS[@]}"; do
  listDir "$THE_DIR"
done