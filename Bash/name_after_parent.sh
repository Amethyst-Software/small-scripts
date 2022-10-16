#!/bin/bash

# Name After Parent
# Names each file after its parent folder by attaching the parent folder name
# to the beginning of the file name. If you pass in "seq" as the third parameter,
# the file name will be replaced with a number based on its existing alpha-
# betical order in the folder.
# Parameter 1 is the directory with the files to rename.
# Parameter 2 is the suffix of the files to rename.
# (optional) Add the argument "seq" if you want the files sequentially numbered.
# (optional) Add the argument "dry" if you want to see a dry-run of the operation.

# Set the field separator to a newline to avoid spaces in paths breaking our
# variable-setting
IFS="
"

PARENT_DIR="$1"
TARGET_SUFFIX="$2"
NAME_SEQ=0
DRY_RUN=0

function makeAbsPath()
{
   if [ -a "$1" ]; then
      # If it begins with "/", it's already an absolute path
      if [[ "$1" == /* ]]; then
         echo $1
      # If it's a directory, 'pwd' the full path
      elif [ -d "$1" ]; then
         CURR_DIR=$(pwd)
         echo $(cd "$1"; pwd)
         cd "$CURR_DIR"
      # If it's a file, get the full parent path and add the file name onto it
      elif [ -f "$1" ]; then
         CURR_DIR=$(pwd)
         ABSPATH=$(cd $(dirname "$1"); pwd)
         echo $ABSPATH/$(basename "$1")
         cd "$CURR_DIR"
      fi
   else
      echo "Error: Could not find file or directory \"$1\"."
      exit
   fi
}

# Process arguments
if [ ! -d "$PARENT_DIR" ]; then
   echo "The directory '$PARENT_DIR' does not exist!"
   exit
fi

if [ "$3" == "seq" ] || [ "$4" == "seq" ]; then
   NAME_SEQ=1
fi

if [ "$3" == "dry" ] || [ "$4" == "dry" ]; then
   DRY_RUN=1
fi

# Main loop
FOUND=0
for FILE in `find -s "$PARENT_DIR" -depth 1 -name "*.$TARGET_SUFFIX"`; do
   let FOUND+=1

   # Get all path info
   FULL_FILE_PATH=$(makeAbsPath "$FILE")
   FULL_PARENT_PATH=$(makeAbsPath "$PARENT_DIR")
   PARENT_DIR_NAME=${FULL_PARENT_PATH##*/}
   FILE_NAME=$(basename "$FILE")

   # Construct new name
   if [ $NAME_SEQ -eq 0 ]; then
      NEW_FILE_NAME=$PARENT_DIR_NAME-$FILE_NAME
   else
      NEW_FILE_NAME=$PARENT_DIR_NAME-$FOUND.$TARGET_SUFFIX
   fi

   # Apply new name
   if [ $DRY_RUN -eq 0 ]; then
      mv "$FULL_FILE_PATH" "$FULL_PARENT_PATH/$NEW_FILE_NAME"
   else
      echo mv $FULL_FILE_PATH $FULL_PARENT_PATH/$NEW_FILE_NAME
   fi
done

STR_FILES="files"
if [ $FOUND -eq 1 ]; then
   STR_FILES="file"
fi

echo "Renamed $FOUND $STR_FILES."