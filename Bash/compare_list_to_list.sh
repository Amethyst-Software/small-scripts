#!/bin/bash

# Compare List to List
# Looks for every line of File A in File B and prints the results. Pass "f" or "m"
# as an optional third parameter to only show found or missing lines.

FILE_A="$1"
FILE_B="$2"
ONLY_PRINT=
FOUND=0
MISSING=0

if [ $# -eq 3 ]; then
   ONLY_PRINT=$3
fi

while IFS= read -r line
do
   # Skip empty lines
   if [ -z "$line" ]; then
      continue
   fi
   
   if grep -F -q -- "$line" "$FILE_B"; then
      let FOUND+=1
      if [ -z "$ONLY_PRINT" ] || [ "$ONLY_PRINT" == "f" ]; then
         echo "FOUND: $line"
      fi
   else
      let MISSING+=1
      if [ -z "$ONLY_PRINT" ] || [ "$ONLY_PRINT" == "m" ]; then
         echo "NOT FOUND: $line"
      fi
   fi
done < "$FILE_A"

echo "Found $FOUND lines in both files and failed to find $MISSING lines in File B."