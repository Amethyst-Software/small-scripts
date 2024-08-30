#!/bin/bash

# Collect File Suffixes
# A script which collects and prints out all the unique file suffixes in a directory,
# and the count of files with each suffix. The only parameter required is the
# directory in which to recursively look.

IFS="
"

SEARCH_PATH=$1
SORT_BY_SUFFIX_COUNT=0
declare -a SUFFIXES=()
declare -a SUFFIX_COUNTS=()
LOOKED_AT=0

if [ ! -d "$SEARCH_PATH" ]; then
   echo "Error: \"$SEARCH_PATH\" does not exist. Aborting."
   exit
fi

if [ $# -eq 2 ]; then
   if [ $2 == "--count-sort" ]; then
      SORT_BY_SUFFIX_COUNT=1
   fi
fi

# The final output of suffixes and their counts is put in a function so we can
# collect all the output and sort it
function printSuffixes()
{
   # Find longest suffix or highest suffix count so we can get its length
   LONGEST=0
   for ((i = 0; i < ${#SUFFIXES[@]}; ++i)); do
      if [ $SORT_BY_SUFFIX_COUNT -eq 0 ]; then
         if [ ${#SUFFIXES[$i]} -gt $LONGEST ]; then
            LONGEST=${#SUFFIXES[$i]}
         fi
      else
         if [ ${#SUFFIX_COUNTS[$i]} -gt $LONGEST ]; then
            LONGEST=${#SUFFIX_COUNTS[$i]}
         fi
      fi
   done
   
   # Print results in order they were found; the 'sort' call at the end of the script
   # will take care of the rest
   for ((i = 0; i < ${#SUFFIXES[@]}; ++i)); do
      STR_FILES="files"
      if [ ${SUFFIX_COUNTS[$i]} -eq 1 ]; then
         STR_FILES="file"
      fi
      
      # Depending on which attribute we are sorting by at the bottom of the script,
      # print that attribute first
      if [ $SORT_BY_SUFFIX_COUNT -eq 0 ]; then
         printf "%${LONGEST}s: %d %s\n" ${SUFFIXES[$i]} ${SUFFIX_COUNTS[$i]} $STR_FILES
      else
         printf "%${LONGEST}d %5s: %s\n" ${SUFFIX_COUNTS[$i]} $STR_FILES ${SUFFIXES[$i]}
      fi
   done
}

for FILE in `find "$SEARCH_PATH" -type f`; do
   FILE_NAME=$(echo "$FILE" | sed 's/.*\///') # clip file name from whole path

   # If this is not a file with a name and suffix, skip it
   if [[ ! "$FILE_NAME" =~ [[:print:]]+\.[[:alnum:]]+$ ]]; then
      continue
   fi

   FILE_SUFFIX=${FILE_NAME##*.} # clip suffix from file name
   if [ -z "$FILE_SUFFIX" ]; then
      echo "Got empty file suffix from '$FILE_NAME'."
      continue
   fi

   # Search for suffix in collection we've made so far
   shopt -s nocasematch
   COLLECTED=0
   for ((i = 0; i < ${#SUFFIXES[@]}; ++i)); do
      if [ "${SUFFIXES[$i]}" == $FILE_SUFFIX ]; then
         let SUFFIX_COUNTS[$i]+=1
         COLLECTED=1
      fi
   done
   shopt -u nocasematch

   # If we haven't seen this suffix before now, add it to the array
   if [ $COLLECTED -eq 0 ]; then
      SUFFIXES+=($FILE_SUFFIX)
      SUFFIX_COUNTS+=(1)
   fi

   let LOOKED_AT+=1
done

echo "Looked at $LOOKED_AT files. The suffixes found were:"
if [ $SORT_BY_SUFFIX_COUNT -eq 0 ]; then
   printSuffixes | sort
else
   printSuffixes | sort -r # descending order by most common suffix
fi