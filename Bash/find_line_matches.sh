#!/bin/bash

# Find Line Matches
# Search the text file given as parameter 2 for each line in the text
# file given in parameter 1, and print out the matches.

FILE_A=$1
FILE_B=$2
SEARCHED=0

# Set the field separator to a newline to avoid spaces in paths breaking
# our variable-setting
IFS="
"

for LINE in `cat "$FILE_A"`; do
   grep "$LINE" "$FILE_B"
   let SEARCHED+=1
   if [ $((SEARCHED % 10)) == 0 ]; then
      echo "$SEARCHED lines done."
   fi
done