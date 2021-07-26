#!/bin/bash

# Update MacPorts
# A shortcut for updating MacPorts and my installed ports, so I don't have to remember
# the commands. Then offers to clear out inactive older versions of installed ports.

UPDATED_MACPORTS=0
OUTDATED_PORTS=0
UPGRADED_PORTS=0
CLEARED_INACTIVE=0

which port > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'port' (MacPorts) does not appear to be installed, so there is nothing to update!" | fmt -w 80
   exit
fi

function exitNicely()
{
   declare -a TASKS_DONE=(MacPorts "was not" updated. Installed ports "were not" upgraded. "Inactive ports were cleared.")
   if [ $UPDATED_MACPORTS -eq 1 ]; then TASKS_DONE[1]="was"; fi
   if [ $OUTDATED_PORTS -eq 0 ]; then TASKS_DONE[5]="did not need to be"; fi
   if [ $UPGRADED_PORTS -eq 1 ]; then TASKS_DONE[5]="were"; fi
   if [ $CLEARED_INACTIVE -eq 0 ]; then TASKS_DONE[7]=""; fi
   TASKS_STR=${TASKS_DONE[@]}
   echo "$TASKS_STR" | fmt -w 80
   exit
}

sudo port selfupdate
UPDATED_MACPORTS=1

echo "------------------------"

OUTDATED_RESULT=$(port outdated | tee /dev/tty)
if [ "$OUTDATED_RESULT" == "No installed ports are outdated." ]; then
   exitNicely
else
   OUTDATED_PORTS=1
fi

echo "------------------------"

echo "Do you wish to upgrade these ports? (y/N)"

read the_answer

if [ -z "$the_answer" ] || [ "$the_answer" != "y" ]; then
   exitNicely
fi

sudo port upgrade outdated
UPGRADED_PORTS=1

echo "------------------------"

echo "The following old versions of ports are inactive:"

port space --units MB inactive

echo "------------------------"

echo "Do you wish to clear the inactive ports? (y/N)"

read the_answer

if [ -z "$the_answer" ] || [ "$the_answer" != "y" ]; then
   exitNicely
fi

sudo port uninstall inactive
CLEARED_INACTIVE=1

echo "------------------------"

exitNicely