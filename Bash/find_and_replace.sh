#!/bin/bash

# Find and Replace
# Look in the specified file for "in" terms 1 and 2, replacing them
# with "out" terms 1 and 2. The results are output to a new file.

IFS="
"

# Process arguments
IN_FILE="$1"
IN_TERM1="$2"
OUT_TERM1="$3"
IN_TERM2="$4"
OUT_TERM2="$5"

# Set up globals
OUT_FILE="${IN_FILE%.txt}-out.txt"
FIRST_WRITE=1
CUR_LINE=1

# Determine actual line count of file by parsing 'wc' output
IFS=" "
WC_OUTPUT=$(wc -l "$IN_FILE")
declare -a WC_OUTPUT_ARRAY=($WC_OUTPUT)
IN_SIZE=${WC_OUTPUT_ARRAY[0]}
IFS="
"

# Correct line count if the file does not end in a newline
LAST_CHAR=$(tail -c -1 "$IN_FILE")
if [ "$LAST_CHAR" != "\n" ]; then
   let IN_SIZE+=1
fi

# Run through lines of file, making substitutions with 'sed'
for THE_LINE in `cat "$IN_FILE"`; do
   # Perform substitutions
   NEW_LINE=$(echo $THE_LINE | sed "s/$IN_TERM1/$OUT_TERM1/")
   if [ ! -z "$IN_TERM2" ] && [ ! -z "$OUT_TERM2" ]; then
      NEW_LINE=$(echo $NEW_LINE | sed "s/$IN_TERM2/$OUT_TERM2/")
   fi

   # If we're writing our first line, don't append, so as to clear the file
   # if it exists
   if [ $FIRST_WRITE -eq 1 ]; then
      echo $NEW_LINE > "$OUT_FILE"
      FIRST_WRITE=0
   else
      # If we're writing the last line, don't add a newline
      if [ $CUR_LINE -eq $IN_SIZE ]; then
         echo -n $NEW_LINE >> "$OUT_FILE"
      else
         echo $NEW_LINE >> "$OUT_FILE"
      fi
   fi

   let CUR_LINE+=1
done