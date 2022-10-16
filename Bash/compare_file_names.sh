#!/bin/bash

# Compare File Names
# Looking at the two specified directories, notes which files are only in one place. Pass
# "--no-suffix" as an additional argument if you want to compare files without their
# suffixes (e.g. "Something.jpg" in dir A would match with "Something.png" in dir B).
# Note that the directory comparison is not recursive.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----|

IFS="
"

COMPARE_DIR1=""
COMPARE_DIR2=""
IGNORE_SUFFIX=0
UNIQUE_DIR1=0
UNIQUE_DIR2=0

# If the supplied argument is a directory, place it in UNIQUE_DIR1 or UNIQUE_DIR2
function checkIfDir()
{
   if [ -d "$1" ]; then
      if [ -z "$COMPARE_DIR1" ]; then
         COMPARE_DIR1="$1"
      elif [ -z "$COMPARE_DIR2" ]; then
         COMPARE_DIR2="$1"
      fi
   else
      echo "Directory '$1' does not exist!"
   fi
}

# Return "file" if the argument is 1, otherwise return "files"
function pluralCheckFile()
{
   if [ $1 -ne 1 ]; then
      echo "files"
   else
      echo "file"
   fi
}

# Process arguments
if [[ $# -ne 2 ]] && [[ $# -ne 3 ]]; then
   echo "You must pass in two directories to compare."
   exit
fi

while (( "$#" )); do
   case "$1" in
      --no-suffix ) IGNORE_SUFFIX=1; shift;;
      * )           checkIfDir $1; shift;;
   esac
done

if [ -z "$COMPARE_DIR1" ] || [ -z "$COMPARE_DIR2" ]; then
   echo "Did not receive two directories to compare."
   exit
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
if [ $IGNORE_SUFFIX -eq 1 ]; then
   echo -n "While ignoring differences in suffixes, found "
else
   echo -n "Found "
fi
echo "$UNIQUE_DIR1 $(pluralCheckFile $UNIQUE_DIR1) unique to directory A (out of $TOTAL_DIR1 $(pluralCheckFile $TOTAL_DIR1)) and $UNIQUE_DIR2 $(pluralCheckFile $UNIQUE_DIR2) unique to directory B (out of $TOTAL_DIR2 $(pluralCheckFile $TOTAL_DIR2))."