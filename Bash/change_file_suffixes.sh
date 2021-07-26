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

cd "$TARGET_DIR"

for FN in `find .`; do
   if [[ $FN == $TARGET_SUFFIX ]]; then
      FN_BASE=${FN%.*}
      echo "Renaming $FN to '$FN_BASE$NEW_SUFFIX'..."
      mv $FN $FN_BASE$NEW_SUFFIX
      let RENAMED+=1
   fi
done

if [ $RENAMED -eq 1 ]; then
   FILES="file"
fi

echo "Renamed $RENAMED $FILES."