#!/bin/bash

# Run Script with Args from File
# Taking a path to a script and a path to a text file with an argument on each line, passes
# the arguments to the script. Useful when you have a lot to say to a script and don't want
# to always type it on the command line or create a very long alias. Each line in the text
# file should be formatted like so:
# --some_arg "arg_value"
# ...or however the script expects its arguments to look. Technically you can place
# multiple args on one line since they are going to get assembled into a single string when
# passed to the script. The arguments the script supports are:
# --script "/full/path/to/script"
# --arglist "/full/path/to/text file"
# --echo
# The "--echo" argument will print out the assembled command that is being run before
# running it.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---|

IFS="
"

SCRIPT_PATH=""
ARGS_PATH=""
ECHO=0

# Process arguments
while (( "$#" )); do
   # Shift 2 spaces unless that takes us past end of argument array
   SAFE_SHIFT=2
   if [ "$#" -eq 1 ]; then
      SAFE_SHIFT=1
   fi

   case "$1" in
      --script )  SCRIPT_PATH="$2"; shift $SAFE_SHIFT;;
      --arglist ) ARGS_PATH="$2"; shift $SAFE_SHIFT;;
      --echo )    ECHO=1; shift;;
      * )         echo "Unrecognized argument $1."; exit;;
   esac
done

# Check arguments
if [ -z "$SCRIPT_PATH" ] || [ -z "$ARGS_PATH" ]; then
   echo "You need to specify a path to a Bash script with '--script' and a path to a text file containing arguments to pass to the script using '--arglist'. Exiting."
   exit
fi
if [ ! -f "$SCRIPT_PATH" ]; then
   echo "No file found at script path '$SCRIPT_PATH'. Exiting."
   exit
fi
if [ ! -f "$ARGS_PATH" ]; then
   echo "No file found at arglist path '$ARGS_PATH'. Exiting."
   exit
fi

# Build command
COMMAND="bash \"$SCRIPT_PATH\""
for THE_LINE in `cat "$ARGS_PATH"`; do
   COMMAND="$COMMAND $THE_LINE"
done

# Print and run command
if [ $ECHO -eq 1 ]; then
   echo "Executing:"
   echo $(tput bold)$COMMAND$(tput sgr0)
fi
eval $COMMAND