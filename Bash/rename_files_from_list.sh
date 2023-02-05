#!/bin/bash

# Rename Files from List
# Looks up each file/folder in list 1 and renames it with the text
# on the same line of list 2.

IFS="
"

RENAME_DIR=""
SOURCE_FILE=""
TARGET_FILE=""

# Process arguments
while (( "$#" >= 2 )); do
  case "$1" in
      --dir )        RENAME_DIR="$2"; shift 2;;
      --names-from ) SOURCE_FILE="$2"; shift 2;;
      --names-to )   TARGET_FILE="$2"; shift 2;;
      * )            echo "Unrecognized argument $1."; exit;;
   esac
done

if [ -z "$RENAME_DIR" ] || [ -z "$SOURCE_FILE" ] || [ -z "$TARGET_FILE" ]; then
   echo "You need to specify three arguments:"
   echo "  '--dir': a directory with the contents to be renamed"
   echo "  '--names-from': a plain-text file with the items that will be searched for and renamed"
   echo "  '--names-to': a plain-text file with the new names for each item"
   echo "The text files should list one item on each line and use paths that are relative to the top-level directory given with '--dir'."
   exit
fi

if [ ! -d "$RENAME_DIR" ]; then
   echo "There is no directory at '$RENAME_DIR'!"
   exit
fi

if [ ! -f "$SOURCE_FILE" ]; then
   echo "The file '$SOURCE_FILE' doesn't exist!"
   exit
fi

if [ ! -f "$TARGET_FILE" ]; then
   echo "The file '$TARGET_FILE' doesn't exist!"
   exit
fi

# Get source file's line count
NUM_LINES=$(wc -l "$SOURCE_FILE")
NUM_LINES=$(echo $NUM_LINES | egrep -o "[[:digit:]]* ")
NUM_LINES=$(echo $NUM_LINES | tr -d '[:space:]')
LAST_CHAR=$(tail -c -1 "$SOURCE_FILE")
if [ "$LAST_CHAR" != "\n" ]; then
   let NUM_LINES+=1
fi

# Copy and name files
CUR_LINE=1
#NUM_LINES=5
while (( $CUR_LINE <= $NUM_LINES )); do
   TO_FIND=$(tail -n+$CUR_LINE "$SOURCE_FILE" | head -n1)
   
   if [ "${TO_FIND:$((${#TO_FIND}-4)):4}" == "Icon" ]; then
      echo "Skipping Icon file."
      let CUR_LINE+=1
      continue
   fi
   
   if [ ! -f "$RENAME_DIR/$TO_FIND" ]; then
      echo "Did not find '$RENAME_DIR/$TO_FIND'."
   else
      NEW_NAME=$(tail -n+$CUR_LINE "$TARGET_FILE" | head -n1)
      NEW_LOC="$RENAME_DIR/$NEW_NAME"
      echo mkdir -p ${NEW_LOC%/*}
      echo mv "$RENAME_DIR/$TO_FIND" "$NEW_LOC"
   fi
   
   let CUR_LINE+=1
done