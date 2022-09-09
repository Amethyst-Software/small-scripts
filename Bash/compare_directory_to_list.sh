#!/bin/bash

# Compare Directory to List
# Looks in the directory specified in parameter 1 for the file names
# listed in the text file specified in parameter 2 and vice versa,
# noting which file names are only in one place. File suffixes are
# ignored in this search.

IFS="
"

SEARCH_DIR=$1
SEARCH_TXT=$2
UNIQUE_DIR=0
UNIQUE_TXT=0

# Check parameter input
if [ $# -ne 2 ]; then
   echo "You must pass in a directory to search and a text file to read."
   exit
fi

if [ ! -d "$SEARCH_DIR" ]; then
   echo "The directory $SEARCH_DIR does not exist."
   exit
fi

if [ ! -f "$SEARCH_TXT" ]; then
   echo "The file $SEARCH_TXT does not exist."
   exit
fi

# Get total file counts
IFS=" "

LS_OUTPUT=$(ls "$SEARCH_DIR" | wc -l)
declare -a LS_OUTPUT_ARRAY=($LS_OUTPUT)
DIR_FILES=${LS_OUTPUT_ARRAY[0]}

WC_OUTPUT=$(cat "$SEARCH_TXT" | wc -l)
declare -a WC_OUTPUT_ARRAY=($WC_OUTPUT)
TXT_FILES=${WC_OUTPUT_ARRAY[0]}

# Correct line count if the file does not end in a newline
LAST_CHAR=$(tail -c -1 "$SEARCH_TXT")
if [ "$LAST_CHAR" != "\n" ]; then
   let TXT_FILES+=1
fi

IFS="
"

# Compare directory to list
for THE_FILE in `ls "$SEARCH_DIR"`; do
   RESULT=""
   RESULT=`grep "${THE_FILE%.*}" "$SEARCH_TXT"`
   if [ -z "$RESULT" ]; then
      echo "${THE_FILE%.*} exists as a file but is not in the list."
      let UNIQUE_DIR+=1
   fi
done

# Compare list to directory
for THE_LINE in `cat "$SEARCH_TXT"`; do
   RESULT=""
   RESULT=`find "$SEARCH_DIR" -name "${THE_LINE%.*}*" -type f`
   if [ -z "$RESULT" ]; then
      echo "${THE_LINE%.*} is in the list but does not exist as a file."
      let UNIQUE_TXT+=1
   fi
done

STR_FILES="files"
if [ $UNIQUE_DIR -eq 1 ]; then
   STR_FILES="file"
fi
STR_FILE_NAMES="file names"
if [ $UNIQUE_TXT -eq 1 ]; then
   STR_FILE_NAMES="file name"
fi

echo "Found $UNIQUE_DIR $STR_FILES unique to the search directory (out of $DIR_FILES files) and $UNIQUE_TXT $STR_FILE_NAMES unique to the text file (out of $TXT_FILES names)."