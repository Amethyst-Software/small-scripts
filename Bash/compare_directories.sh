#!/bin/bash

# Compare Directories
# Looks in the directories specified in parameters 1 and 2 and notes
# which files are only in one place.

IFS="
"

SEARCH_DIR1=$1
SEARCH_DIR2=$2
UNIQUE_DIR1=0
UNIQUE_DIR2=0

# Check parameter input
if [ $# -ne 2 ]; then
   echo "You must pass in two directories to search."
   exit
fi

if [ ! -d "$SEARCH_DIR1" ]; then
   echo "The directory $SEARCH_DIR1 does not exist."
   exit
fi

if [ ! -d "$SEARCH_DIR2" ]; then
   echo "The directory $SEARCH_DIR2 does not exist."
   exit
fi

# Get total file counts
IFS=" "
LS_OUTPUT=$(ls "$SEARCH_DIR1" | wc -l)
declare -a LS_OUTPUT_ARRAY=($LS_OUTPUT)
TOTAL_DIR1=${LS_OUTPUT_ARRAY[0]}
LS_OUTPUT=$(ls "$SEARCH_DIR2" | wc -l)
declare -a LS_OUTPUT_ARRAY=($LS_OUTPUT)
TOTAL_DIR2=${LS_OUTPUT_ARRAY[0]}
IFS="
"

# Compare directories
echo "Directory A =
 $SEARCH_DIR1
Directory B =
 $SEARCH_DIR2"

echo "--Searching for unique files in Directory A--"
for THE_FILE in `ls "$SEARCH_DIR1"`; do
   RESULT=""
   RESULT=`find "$SEARCH_DIR2" -name "$THE_FILE" -type f`
   if [ -z "$RESULT" ]; then
      echo $THE_FILE
      let UNIQUE_DIR1+=1
   fi
done

echo "--Searching for unique files in Directory B--"
for THE_FILE in `ls "$SEARCH_DIR2"`; do
   RESULT=""
   RESULT=`find "$SEARCH_DIR1" -name "$THE_FILE" -type f`
   if [ -z "$RESULT" ]; then
      echo $THE_FILE
      let UNIQUE_DIR2+=1
   fi
done

STR_FILES1="files"
if [ $UNIQUE_DIR1 -eq 1 ]; then
   STR_FILES="file"
fi
STR_FILES2="files"
if [ $UNIQUE_DIR2 -eq 1 ]; then
   STR_FILES2="file"
fi

echo "Found $UNIQUE_DIR1 $STR_FILES1 unique to the directory A (out of $TOTAL_DIR1 files) and $UNIQUE_DIR2 $STR_FILES2 unique to directory B (out of $TOTAL_DIR2 files)."