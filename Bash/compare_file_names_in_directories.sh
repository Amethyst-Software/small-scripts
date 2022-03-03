#!/bin/bash

# Compare File Names in Directories
# Looks in the directories specified in parameters 1 and 2 and notes
# which files are only in one place. Pass "--no-suffix" as the third
# argument if you want to compare files without their suffixes (e.g.
# "Something.jpg" in dir A matches with "Something.png" in dir B).
# Note that the directory comparison is not recursive.

IFS="
"

COMPARE_DIR1=$1
COMPARE_DIR2=$2
IGNORE_SUFFIX=0
UNIQUE_DIR1=0
UNIQUE_DIR2=0

# Check parameter input
if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
   echo "You must pass in two directories to compare."
   exit
fi

if [ ! -d "$COMPARE_DIR1" ]; then
   echo "The directory $COMPARE_DIR1 does not exist."
   exit
fi

if [ ! -d "$COMPARE_DIR2" ]; then
   echo "The directory $COMPARE_DIR2 does not exist."
   exit
fi

if [ "$3" == "--no-suffix" ]; then
   IGNORE_SUFFIX=1
fi

# Compare directories
echo "Directory A =
 $COMPARE_DIR1
Directory B =
 $COMPARE_DIR2"
if [ $IGNORE_SUFFIX -eq 1 ]; then
   echo "Ignoring differences in file suffixes."
fi

# Get directory contents and file count
declare -a LISTING_DIR1=($(find -s "$COMPARE_DIR1" -type f ! -name ".DS_Store" -depth 1))
TOTAL_DIR1=$(find "$COMPARE_DIR1" -type f ! -name ".DS_Store" -depth 1 | wc -l | tr -d ' ')
declare -a LISTING_DIR2=($(find -s "$COMPARE_DIR2" -type f ! -name ".DS_Store" -depth 1))
TOTAL_DIR2=$(find "$COMPARE_DIR2" -type f ! -name ".DS_Store" -depth 1 | wc -l | tr -d ' ')

echo "--Searching for unique files in Directory A--"
for THE_LINE1 in "${LISTING_DIR1[@]}"; do
   THE_FILE1=${THE_LINE1##*/}
   if [ $IGNORE_SUFFIX -eq 1 ]; then
      THE_FILE1="${THE_FILE1%.*}"
   fi

   MATCHED=0
   for THE_LINE2 in "${LISTING_DIR2[@]}"; do
      let CHECKED2+=1
      THE_FILE2=${THE_LINE2##*/}
      if [ $IGNORE_SUFFIX -eq 1 ]; then
         THE_FILE2="${THE_FILE2%.*}"
      fi

      if [ "$THE_FILE1" == "$THE_FILE2" ]; then
         MATCHED=1
         break
      fi
   done

   if [ $MATCHED -eq 0 ]; then
      echo ${THE_LINE1##*/}
      let UNIQUE_DIR1+=1
   fi
done

echo "--Searching for unique files in Directory B--"
for THE_LINE2 in "${LISTING_DIR2[@]}"; do
   THE_FILE2=${THE_LINE2##*/}
   if [ $IGNORE_SUFFIX -eq 1 ]; then
      THE_FILE2="${THE_FILE2%.*}"
   fi

   MATCHED=0
   for THE_LINE1 in "${LISTING_DIR1[@]}"; do
      THE_FILE1=${THE_LINE1##*/}
      if [ $IGNORE_SUFFIX -eq 1 ]; then
         THE_FILE1="${THE_FILE1%.*}"
      fi

      if [ "$THE_FILE2" == "$THE_FILE1" ]; then
         MATCHED=1
         break
      fi
   done

   if [ $MATCHED -eq 0 ]; then
      echo ${THE_LINE2##*/}
      let UNIQUE_DIR2+=1
   fi
done

# Summarize our findings
STR_FILES1="files"
if [ $UNIQUE_DIR1 -eq 1 ]; then
   STR_FILES="file"
fi
STR_FILES2="files"
if [ $UNIQUE_DIR2 -eq 1 ]; then
   STR_FILES2="file"
fi

if [ $IGNORE_SUFFIX -eq 1 ]; then
   echo -n "While ignoring differences in suffixes, found "
else
   echo -n "Found "
fi
echo "$UNIQUE_DIR1 $STR_FILES1 unique to directory A (out of $TOTAL_DIR1 files) and $UNIQUE_DIR2 $STR_FILES2 unique to directory B (out of $TOTAL_DIR2 files)."