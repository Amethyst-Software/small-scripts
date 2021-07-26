#!/bin/bash

# Get Fork Sizes
# Adds up the sizes of the files in the supplied directory separately by data fork and by
# resource fork, then simulates the buggy "size on disk" that Finder's Get Info window
# will display for any folder with multi-fork files on an APFS disk.
# Parameters:
# 1. (required) Directory to get file sizes for.
# 2. (optional) Supply "--list-files" to see a by-fork breakdown of each file.
# Recommended width:
# |--------------------------------------------------------------------------------------|

IFS="
"

# Argument processing
if [ -z "$1" ]; then
   echo "You must supply a directory to look inside of!"
   exit
fi

if [ ! -d "$1" ]; then
   echo "Directory $1 does not exist!"
   exit
fi

BY_FILE=0
if [ ! -z "$2" ]; then
   if [ "$2" == "--list-files" ]; then
      BY_FILE=1
   else
      echo "Unrecognized argument $2. Exiting."
      exit
   fi
fi

# Logical sizes (actual bytes)
BYTE_DATA_TOTAL=0
BYTE_RSRC_TOTAL=0

# Physical sizes ("size on disk")
DISK_DATA_TOTAL=0
DISK_RSRC_TOTAL=0

# Number of alloc blocks occupied
BLOCK_DATA_TOTAL=0
BLOCK_RSRC_TOTAL=0

# Number of files
FILE_DATA_TOTAL=0
FILE_RSRC_TOTAL=0

# Used for recognizing icon files in order to make Get Info prediction more accurate
CR_CHAR=$(printf "\x0d")
ICON_SIZE=0

# Pluralize the string in parameter 1 if the number in parameter 2 is not 1
function pluralCheck()
{
   if [ $2 -ne 1 ]; then
      echo $(commaPrint $2) $1s
   else
      echo $(commaPrint $2) $1
   fi
}

# Print a number in regional comma format
function commaPrint()
{
   THE_NUM=$(printf "%'.f" $1)
   echo $THE_NUM
}

# Loop over all files in ASCIIbetical order
IS_ICON=0
for LINE in `find -s "$1" -type f`; do
   let FILE_DATA_TOTAL+=1
   NAME=$(basename "$LINE")

   # If this file is "Icon\r", fix the name so it displays properly and then trip the
   # flag, which will be reset at the bottom of the loop
   if [ "$NAME" == Icon${CR_CHAR} ]; then
      IS_ICON=1
      NAME="Icon"
   fi

   # Call 'ls' on this file and then read the 5th word (size of data fork in bytes)
   IFS=" "
   declare -a DATA_LINE=(`ls -al "$LINE"`)
   BYTE_SIZE_DATA=${DATA_LINE[4]}
   let BYTE_DATA_TOTAL+=$BYTE_SIZE_DATA

   # Determine how many 4KiB alloc blocks it takes to hold the data fork
   DISK_SIZE_DATA=0
   BLOCKS_DATA=0
   a=$BYTE_SIZE_DATA
   while [ $a -gt 0 ]; do
      let a-=4096
      let BLOCKS_DATA+=1
      let DISK_SIZE_DATA+=4096
   done

   if [ $BY_FILE -eq 1 ]; then
      echo -e "\033[38;5;63m$NAME data: $(commaPrint $BYTE_SIZE_DATA) ($(pluralCheck block $BLOCKS_DATA))\033[0m"
   fi
   
   # Look for a resource fork in this file, then do the same if present
   DISK_SIZE_RSRC=0
   BLOCKS_RSRC=0
   if [ -f "$LINE/..namedfork/rsrc" ]; then
      let FILE_RSRC_TOTAL+=1
      declare -a RSRC_LINE=(`ls -al "$LINE/..namedfork/rsrc"`)
      BYTE_SIZE_RSRC=${RSRC_LINE[4]}
      let BYTE_RSRC_TOTAL+=${RSRC_LINE[4]}
      a=$BYTE_SIZE_RSRC
      while [ $a -gt 0 ]; do
         let a-=4096
         let BLOCKS_RSRC+=1
         let DISK_SIZE_RSRC+=4096
      done
      if [ $BY_FILE -eq 1 ]; then
         echo -e "\033[38;5;28m$NAME rsrc: $(commaPrint $BYTE_SIZE_RSRC) ($(pluralCheck block $BLOCKS_RSRC))\033[0m"
      fi
   fi

   if [ $BY_FILE -eq 1 ]; then
      echo "$NAME on disk: $(commaPrint $((DISK_SIZE_DATA+DISK_SIZE_RSRC))) ($(pluralCheck block $((BLOCKS_DATA+BLOCKS_RSRC))))"
   fi

   # Add this file's numbers to the running grand totals
   let DISK_DATA_TOTAL+=DISK_SIZE_DATA
   let DISK_RSRC_TOTAL+=DISK_SIZE_RSRC
   let BLOCK_DATA_TOTAL+=BLOCKS_DATA
   let BLOCK_RSRC_TOTAL+=BLOCKS_RSRC
   if [ $IS_ICON -eq 1 ]; then
      let ICON_SIZE+=DISK_SIZE_RSRC
      IS_ICON=0
   fi
done

# Output grand totals for directory
echo "Results for $1:"
echo -e "\033[38;5;63mTotal of data forks in $(pluralCheck file $FILE_DATA_TOTAL) is $(commaPrint $BYTE_DATA_TOTAL) ($(commaPrint $DISK_DATA_TOTAL) ($(pluralCheck block $BLOCK_DATA_TOTAL)) on disk).\033[0m" | fold -s
echo -e "\033[38;5;28mTotal of rsrc forks in $(pluralCheck file $FILE_RSRC_TOTAL) is $(commaPrint $BYTE_RSRC_TOTAL) ($(commaPrint $DISK_RSRC_TOTAL) ($(pluralCheck block $BLOCK_RSRC_TOTAL)) on disk).\033[0m" | fold -s
echo "Total of $(pluralCheck file $((FILE_DATA_TOTAL+FILE_RSRC_TOTAL))) is $(commaPrint $((BYTE_DATA_TOTAL+BYTE_RSRC_TOTAL))) ($(commaPrint $((DISK_DATA_TOTAL+DISK_RSRC_TOTAL))) ($(pluralCheck block $((BLOCK_DATA_TOTAL+BLOCK_RSRC_TOTAL)))) on disk)." | fold -s

# Predict the "on disk" number (physical size) that Get Info will list for the directory
# under APFS by adding the smaller fork total twice to the data+fork size total
WRONG_TOTAL=$((DISK_DATA_TOTAL+DISK_RSRC_TOTAL))
if [ $DISK_DATA_TOTAL -lt $DISK_RSRC_TOTAL ]; then
   let WRONG_TOTAL+=DISK_DATA_TOTAL
else
   let WRONG_TOTAL+=DISK_RSRC_TOTAL
fi

# Create human-readable version of size
WRONG_TOTAL_HR=$((WRONG_TOTAL-ICON_SIZE))
SIZE_UNIT=""
SCALE=0
NUM_DEC=0
while [ $(echo $WRONG_TOTAL_HR'>'1000 | bc -l) -eq 1 ]; do
   WRONG_TOTAL_HR=$(echo | awk -v size_bytes=$WRONG_TOTAL_HR '{printf "%f",size_bytes/=1000}')
   let SCALE+=1
done
if [ $SCALE == 0 ]; then
   SIZE_UNIT="bytes"
elif [ $SCALE == 1 ]; then
   SIZE_UNIT="KB"
elif [ $SCALE == 2 ]; then
   SIZE_UNIT="MB"
   NUM_DEC=1
elif [ $SCALE == 3 ]; then
   SIZE_UNIT="GB"
   NUM_DEC=2
else
   SIZE_UNIT="(out of scope!)"
fi

echo -n "Predicted total from Get Info under APFS: "
printf "\"%0.*f $SIZE_UNIT on disk\".\n" $NUM_DEC $WRONG_TOTAL_HR