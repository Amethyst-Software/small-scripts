#!/bin/bash

# Duplicate File and Copy Names
# Duplicates a single file and names each copy after one of the files
# found in a given folder or one of the lines found in a text file.
# An optional suffix can be applied to the duplicated files in place
# of the original.

IFS="
"

COPY_FILE=""
COPY_NAMES=""
DEST_DIR=""
NEW_SUFFIX=""
FROM_FILE=-1

# Process arguments
while (( "$#" >= 2 )); do
  case "$1" in
      --copy-file )  COPY_FILE="$2"; shift 2;;
      --copy-names ) COPY_NAMES="$2"; shift 2;;
      --dest )       DEST_DIR="$2"; shift 2;;
      --new-suffix ) NEW_SUFFIX="$2"; shift 2;;
      * )            echo "Unrecognized argument $1."; exit;;
   esac
done

if [ -z "$COPY_FILE" ] || [ -z "$COPY_NAMES" ] || [ -z "$DEST_DIR" ]; then
   echo "You need to specify three arguments:"
   echo "  '--copy-file': a file to copy"
   echo "  '--copy-names': the source for the names that will be applied to the copies (can be either a text file with a list of names or a directory of files from which to copy the names)"
   echo "  '--dest': a destination direction"
   echo "Optional argument:"
   echo "  '--new-suffix': the suffix to use for the copies, in place of the original file's suffix"
   exit
fi

if [ ! -f "$COPY_FILE" ]; then
   echo "The file '$COPY_FILE' doesn't exist!"
   exit
fi

if [ ! -f "$COPY_NAMES" ]; then
   if [ ! -d "$COPY_NAMES" ]; then
      echo "There is no file or directory at '$COPY_NAMES'!"
      exit
   else
      FROM_FILE=0
   fi
else
   FROM_FILE=1
fi

answer="n"
if [ ! -d "$DEST_DIR" ]; then
   echo "The specified destination directory '$DEST_DIR' doesn't exist. Create it? (y/n)"
   read answer
   if [ "$answer" == "y" ]; then
      mkdir -p "$DEST_DIR"
   else
      echo "Exiting."
      exit
   fi
fi

# Copy and name files
if [ $FROM_FILE -eq 0 ]; then
   for THE_FILE in `ls "$COPY_NAMES"`; do
      if [ -z "$NEW_SUFFIX" ]; then
         cp "$COPY_FILE" "$DEST_DIR/$THE_FILE"
      else
         cp "$COPY_FILE" "$DEST_DIR/${THE_FILE%.*}.$NEW_SUFFIX"
      fi
   done
elif [ $FROM_FILE -eq 1 ]; then
   for THE_LINE in `cat "$NAME_LIST"`; do
      if [ ! -f "$DEST_DIR/$THE_LINE" ]; then
         cp "$COPY_FILE" "$DEST_DIR/$THE_LINE"
      fi
   done
fi