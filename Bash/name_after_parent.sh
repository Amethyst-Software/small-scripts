#!/bin/bash

# Rename Sequentially
# Names each file after its parent folder with a number appended based on its
# existing alphabetical order, e.g. ParentFolder1.jpg, ParentFolder2.jpg, etc.
# Parameter 1 is the directory with the files to rename, and parameter 2 is the
# suffix of the files to rename.

PARENT_DIR="$1"
TARGET_SUFFIX="$2"
FOUND=0

# Set the field separator to a newline to avoid spaces in paths breaking our
# variable-setting
IFS="
"

for FN in `ls -d "$PARENT_DIR"/* | grep "\.${TARGET_SUFFIX}$"`; do
   let FOUND+=1
   DIR_NAME=$(basename $PARENT_DIR)
   NEW_FN=$PARENT_DIR/$DIR_NAME-$FOUND.$TARGET_SUFFIX
   mv "$FN" "$NEW_FN"
done

if [ $FOUND -eq 1 ]; then
   FILES="file"
fi

echo "Renamed $FOUND files."