#!/bin/bash

# Change File Suffixes
# A mass suffix-changing tool which can accept regex patterns, allowing
# multiple suffixes to be matched and set to a new suffix.
# Parameter 1 is the directory to search, parameter 2 is the file suffix or
# suffix pattern to look for, and parameter 3 is the new suffix to replace
# it with.

# Set the field separator to a newline to avoid spaces in paths breaking our
# variable-setting
IFS="
"

TARGET_DIR="$1"
TARGET_SUFFIX="$2"
NEW_SUFFIX="$3"
RENAMED=0
FILES="files"

for FILE in `find -s "$TARGET_DIR" -type f -iname "*.$TARGET_SUFFIX"`; do
   FILE_NAME=$(echo "$FILE" | sed 's/.*\///') # clip file name from whole path
   
   # If this is not a file with a name and suffix, skip it
   if [[ ! "$FILE_NAME" =~ [[:print:]]+\.[[:print:]]+$ ]]; then
      continue
   fi
   
   NEW_FILE="${FILE%.$TARGET_SUFFIX}.$NEW_SUFFIX"
      echo "Renaming $FILE to '$NEW_FILE'..."
      mv $FILE $NEW_FILE
      let RENAMED+=1
done

if [ $RENAMED -eq 1 ]; then
   FILES="file"
fi

echo "Renamed $RENAMED $FILES."