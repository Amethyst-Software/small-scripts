#!/bin/bash

# Find List in Files and Delete
# A program that looks in the directory given in parameter 1 for files with names matching the
# regex pattern given in parameter 2, and moves them to the Trash if their content matches any of
# the terms in a list given in parameter 3.
# Recommended width:
# |---------------------------------------------------------------------------------------------|

# Set the field separator to a newline to avoid spaces in paths breaking our variable-setting
IFS="
"

SEARCH_DIR=$1
SEARCH_FILES=$2
TERM_LIST=$3
FOUND=0
THE_TIME=$(date "+%Y-%m-%d--%H-%M-%S")
TRASH_FOLDER="$HOME/.Trash/Deleted files ($THE_TIME)"
STR_FILES="files"

if [ $# -ne 3 ]; then
   echo "You need to supply this script with (1) the directory to search recursively, (2) the file name regex pattern to search in, and (3) the list of terms to search for."
   exit
fi

if [ ! -d "$SEARCH_DIR" ]; then
   echo "Cannot search directory $SEARCH_DIR, as it does not exist!"
   exit
fi

if [ ! -f "$TERM_LIST" ]; then
   echo "No file found at path $TERM_LIST!"
   exit
fi

mkdir "$TRASH_FOLDER"
if [ ! -d "$TRASH_FOLDER" ]; then
   echo "Could not create the folder \"$TRASH_FOLDER\". Aborting."
   exit
fi

for THE_FILE in `find "$SEARCH_DIR" | grep $SEARCH_FILES`; do
   CONTENTS=`cat "$THE_FILE"`
   RESULT=""
   for THE_TERM in `cat "$TERM_LIST"`; do
      RESULT=`echo $CONTENTS | grep --max-count=1 "$THE_TERM"`
      RESULT_CHARS=`echo -n "$RESULT" | wc -c`
      if [ $RESULT_CHARS -gt 1 ]; then
         THE_FILE_NAME=$(echo "$THE_FILE" | sed 's/.*\///') # clip file name from whole path
         echo "$THE_FILE_NAME matches search term \"$THE_TERM\". Deleting."
         mv "$THE_FILE" "$TRASH_FOLDER"
         let FOUND+=1
         break
      fi
   done
done

if [ $FOUND -eq 1 ]; then
   STR_FILES="file"
fi

echo "Matched and deleted $FOUND $STR_FILES."