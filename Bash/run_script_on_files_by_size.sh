#!/bin/bash

# Run Script on Files by Size
# Looking at the files in a given directory, pass each one to the specified script if it
# is within a certain size range. Parameters:
# 1. Script to run files on.
# 2. Directory to look in for files.
# 3. Minimum size in bytes of files to select.
# 4. Maximum size in bytes of files to select.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----|

IFS="
"

if [ $# -lt 4 ]; then
   echo "You need to supply the following parameters:"
   echo "1. The script to run."
   echo "2. The directory in which to look for files."
   echo "3. The smallest file size to select."
   echo "4. The largest file size to select."
   exit
fi

# Get all files below specified size in given directory, then place them in a sortable
# array
declare -a FILE_DATA=()
for LINE in `find "$2" -type f ! -name ".DS_Store" -depth 1 -ls`; do
   IFS=" "
   declare -a LINE_PARTS=($LINE)
   SIZE=${LINE_PARTS[6]}
   NAME=${LINE##*/}
   if [ $SIZE -ge $3 ] && [ $SIZE -le $4 ]; then
      FILE_DATA+=("$SIZE|$NAME")
   fi
done

# Sort file data array so that files are listed by size
IFS="
"
declare -a SORTED_FILE_DATA=($(sort <<< "${FILE_DATA[*]}"))

# Separate name from file data array and pass each file to the specified script
for THE_FILE in ${SORTED_FILE_DATA[@]}; do
   IFS="|"
   declare -a DATA_PARTS=($THE_FILE)
   FILE_NAME=${DATA_PARTS[1]}
   echo -e "\n---Running script on file $FILE_NAME (${DATA_PARTS[0]} bytes)...---"
   bash "$1" "$2/$FILE_NAME"
done