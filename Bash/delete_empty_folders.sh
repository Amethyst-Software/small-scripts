#!/bin/bash

# Delete Empty Folders
# For the directory passed in, all subfolders which contain no items
# will be deleted.

if [ ! -d "$1" ]; then
   echo "No directory found at '$1'!"
   exit
fi

for FOLDER in $(find -s "$1" ! -wholename ".DS_Store" -type d); do
   ITEM_CT=$(ls "$FOLDER" | wc -l | tr -d '[:space:]')
   if [ "$ITEM_CT" -eq 0 ]; then
      rmdir "$FOLDER"
      if [ $? -ne 0 ]; then
         echo "There was a problem! Aborting."
         exit
      fi
      echo "Removed empty folder '$FOLDER'."
   else
      echo "Skipped non-empty folder '$FOLDER'."
   fi
done