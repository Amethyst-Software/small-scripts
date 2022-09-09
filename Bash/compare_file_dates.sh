#!/bin/bash

# Check for Script Updates
# Compares my personal copies of my Unix scripts to the copies that are linked to online repos where
# they've been uploaded. This script could be used to compare any set of files by mod. date, but it was
# very much written for my personal usage and would need to be adapted in order to be useful for someone
# else.
# Recommended width:
# |-------------------------------------------------------------------------------------------------------|

IFS="
"

SMALL_SCRIPTS_WC="/path/to/dir1"

SMALL_SCRIPTS_REPO="/path/to/dir2"

declare -a OTHER_SCRIPTS_WC=("/path1/to/file1"
"/path1/to/file2")

declare -a OTHER_SCRIPTS_REPO=("/path2/to/file1"
"/path2/to/file2")

FOUND_CHANGE=0
TIME_RESULT=""

# Get the modification time of a file and save it in TIME_RESULT
function getModTime()
{
   if [ ! -f "$1" ]; then
      #echo "File '$1' does not exist!"
      TIME_RESULT=-1
   else
      mod_time=$(stat -s "$1")
      mod_time=${mod_time#*st_mtime=*}
      mod_time=${mod_time%% *}

      if [ -z "$mod_time" ]; then
         echo "Failed to get mod. time of '$1'."
         exit
      fi

      TIME_RESULT=$mod_time
   fi
}

# Check small scripts
for FILE1 in `find -s "$SMALL_SCRIPTS_WC" -type f -name "*.sh"`; do
   getModTime "$FILE1"
   MOD_TIME1=$TIME_RESULT

   # Change the file's path string to be in FOLDER2
   FILE2=${FILE1#$SMALL_SCRIPTS_WC}
   FILE2=${SMALL_SCRIPTS_REPO}${FILE2}

   getModTime "$FILE2"
   MOD_TIME2=$TIME_RESULT

   FILE_NAME=$(basename $FILE1)

   if [ $TIME_RESULT -eq -1 ]; then
      echo "$FILE_NAME has not been added to a repository."
      FOUND_CHANGE=1
   elif [ $MOD_TIME1 -gt $MOD_TIME2 ]; then
      echo "$FILE_NAME has been changed."
      FOUND_CHANGE=1
   elif [ $MOD_TIME1 -lt $MOD_TIME2 ]; then
      echo "$FILE_NAME is somehow newer in the repository."
      FOUND_CHANGE=1
   else
      #echo "$FILE_NAME has not changed."
      echo -n
   fi
done

# Check other scripts
for ((i = 0; i < ${#OTHER_SCRIPTS_WC[@]}; ++i)); do
   EXPANDED_PATH=$(eval echo ${OTHER_SCRIPTS_WC[$i]})
   getModTime "$EXPANDED_PATH"
   MOD_TIME1=$TIME_RESULT

   EXPANDED_PATH=$(eval echo ${OTHER_SCRIPTS_REPO[$i]})
   getModTime "$EXPANDED_PATH"
   MOD_TIME2=$TIME_RESULT

   FILE_NAME=$(basename ${OTHER_SCRIPTS_WC[$i]})

   if [ $TIME_RESULT -eq -1 ]; then
      echo "$FILE_NAME has not been added to a repository."
      FOUND_CHANGE=1
   elif [ $MOD_TIME1 -gt $MOD_TIME2 ]; then
      echo "$FILE_NAME has been changed."
      FOUND_CHANGE=1
   elif [ $MOD_TIME1 -lt $MOD_TIME2 ]; then
      echo "$FILE_NAME is somehow newer in the repository."
      FOUND_CHANGE=1
   else
      #echo "$FILE_NAME has not changed."
      echo -n
   fi
done

if [ $FOUND_CHANGE -eq 0 ]; then
   echo "No scripts have been updated!"
else
   open "$SMALL_SCRIPTS_WC"
   open "$SMALL_SCRIPTS_REPO"
fi