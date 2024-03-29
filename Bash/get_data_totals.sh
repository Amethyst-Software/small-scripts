#!/bin/bash

# Get Data Totals
# A script that reads in the desired directory paths from a file, gets their sizes, then
# totals them by type and prints them out. A secondary mode is provided which simply
# takes a single path, but the script is mainly built around the use of an input file.
#
# Usage:
# get_data_totals.sh --file path/to/file OR
# get_data_totals.sh --dir path/to/dir
#
# The input file should be formatted like this example (the surrounding box is a visual
# aid, not part of the file):
#
# /-------------------------------------\
# |# Input file for get_data_totals.sh	|
# |# Data set: Apps and photos		|
# |					|
# |vol=My Disk 1			|
# |type=Photos				|
# |$HOME/Pictures			|
# |$HOME/Documents/My photos		|
# |-$HOME/Documents/My photos/RAWs	|
# |					|
# |type=Applications			|
# |/Applications			|
# |					|
# |vol=My Disk 2			|
# |type=Games				|
# |/Games				|
# \-------------------------------------/
#
# As seen above, comments are marked with the '#' character, "vol=" sets the current
# volume to the name given, and "type=" is used to group paths under one name. All paths
# should start with '/' and are relative to the volume name previously declared. An
# exception to starting with a '/' is if you are using the shortcut '~' or "$HOME", which
# will expand to have a '/' at the start. A leading '-' character tells the script to
# deduct the size of the path from the type's total. The use of blank lines as whitespace
# is optional.
#
# You can pass the script different input files for different sets of data that you wish
# to tabulate. The script currently does not total types of data across volumes, only
# within them, though that might change in the future.
#
# The script will ask for your 'sudo' password because this enables 'du' to scan more
# directories; without this permission, system directories will be tabulated wrongly.
# There still may be small inaccuracies for directories like /private, since even
# 'sudo'-level permissions are not enough to read some system directories. To see what is
# not being tabulated, remove the "2> /dev/null" from the invocation of 'du' below
# (you'll also have to change the 'printf' command which deletes the previous
# line of output).
#
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- -|

IFS="
"

# Sanity check
if [ $# -ne 2 ]; then
   echo "You need to supply the arguments '--dir path/to/dir' for the directory to get the size of, or else '--file path/to/file' to specify a text file with a list of paths to get the sizes of. Read the comment at the top of this script to learn how to format the text file."
   exit
fi

# Print a raw number of bytes at a human-readable scale
function printHumanReadable()
{
   if [ -z "$1" ]; then
      echo "Did not receive a number as an argument!"
      exit
   fi

   BIG_NUM=$1
   SCALE=0

   while [ $(echo $BIG_NUM'>'1000 | bc -l) -eq 1 ]; do
      BIG_NUM=$(echo | awk -v size_bytes=$BIG_NUM '{printf "%f",size_bytes/=1000}')
      let SCALE+=1
   done

   # Print with precision that matches Finder's Size column
   if [ $SCALE -eq 0 ]; then
      printf "%d bytes" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 1 ]; then
      printf "%d KB" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 2 ]; then
      printf "%.1f MB" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 3 ]; then
      printf "%.2f GB" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 4 ]; then
      printf "%.2f TB" $BIG_NUM $SIZE_UNIT
   else
      echo "Number $1 is out of scope!"
   fi
}

# Load specified file into memory. If we got a path argument, construct fake input file
# around the path.
INPUT_DATA=""
if [ $1 == "--file" ]; then
   if [ ! -f "$2" ]; then
      echo "Input file not found at path $2! Exiting."
      exit
   else
      INPUT_DATA=$(cat $2)
   fi
elif [ $1 == "--dir" ]; then
   # Get name of volume this path is on, since it's not in the path unless the path is on
   # a volume not mounted at '/'
   DEV_NAME=$(df $2 | egrep -o "^/[a-z0-9/]*")
   VOL_NAME_LINE=$(diskutil info $DEV_NAME | egrep "Volume Name")
   VOL_NAME=$(echo ${VOL_NAME_LINE##*:} | tr -d ' ')

   # If this path is on an external volume, it already starts with "/Volumes/X/", so we
   # need to remove that because the code below is going to add it back in based on the
   # "vol=" tag
   SAN_PATH=${2#/Volumes/$VOL_NAME}

   INPUT_DATA="`echo -e "vol=$VOL_NAME\\ntype=Test\\n$SAN_PATH"`"
else
   echo "Unrecognized argument '$1'! Exiting."
   exit
fi

# Call 'sudo' if root access is not currently active on a timer from 'sudo' being used
# recently (i.e., a previous invocation of this script). Otherwise the password prompt
# appears the first time that "sudo du" is called below, which interferes with the
# progress message that is continually cleared and updated.
sudo -nv 2> /dev/null
SUDO_NEEDED=$(echo $?)
if [ $SUDO_NEEDED -eq 1 ]; then
   echo "Please enter your root password so I can more get more accurate sizes for any system directories in the list." | fmt -w 80
   sudo echo "Thank you."
fi

# Read input file into memory
declare -a ITEM_VOL=() # parallel array with next four
declare -a ITEM_TYPE=()
declare -a ITEM_PATH=()
declare -a ITEM_SIZE=()
declare -a ITEM_NEG=()
NUM_ITEMS=0
CUR_VOL="-"
CUR_TYPE="-"
for THE_LINE in `echo "$INPUT_DATA"`; do
   # Ignore comment lines
   if [[ $THE_LINE =~ ^# ]]; then
      continue
   fi

   # If this line is a volume name, read it in
   if [[ $THE_LINE =~ ^vol=[[:print:]]+$ ]]; then
      CUR_VOL=${THE_LINE##vol=}
      if [ -z "$CUR_VOL" ]; then
         echo "Error: Missing volume name after 'vol='."
         exit
      fi
      continue
   fi

   # If this line is a data type, read it in
   if [[ $THE_LINE =~ ^type=[[:print:]]+$ ]]; then
      CUR_TYPE=${THE_LINE##type=}
      if [ -z "$CUR_TYPE" ]; then
         echo "Error: Missing volume name after 'type='."
         exit
      fi
      continue
   fi

   # If this line is asking to be deducted from the total, set the "deduct" flag and
   # remove the '-' from the beginning
   if [[ $THE_LINE =~ ^- ]]; then
      THE_LINE=${THE_LINE#-}
      ITEM_NEG+=(1)
   else
      ITEM_NEG+=(0)
   fi

   # Otherwise this must be a path item, so read it in, invoking 'eval' in order to expand
   # shortcuts like '~' or "$HOME", then make sure it exists
   THE_PATH="$(eval echo "$THE_LINE")"
   if [ -z "$THE_PATH" ]; then
      echo "Error: Failed to read a path from the input file."
      exit
   fi
   FULL_PATH="/Volumes/$CUR_VOL$THE_PATH"
   if [ ! -d "$FULL_PATH" ]; then
      echo "Error: $THE_PATH does not exist on volume $CUR_VOL."
      continue
   fi

   # Store the path and its metadata (data sizes to be determined later)
   ITEM_PATH+=($THE_PATH)
   ITEM_VOL+=($CUR_VOL)
   ITEM_TYPE+=($CUR_TYPE)
   ITEM_SIZE+=(0)
   let NUM_ITEMS+=1
done

# Iterate over path items, filling in size metadata
a=0
echo -n "Getting sizes of directories ($a/$NUM_ITEMS paths processed)..."
while [ "x${ITEM_PATH[$a]}" != "x" ]; do
   # If 'du' is being asked to get the size of /System, mask out the subdir "Volumes"
   # since this is a link in Catalina to the entire volume
   FULL_PATH="/Volumes/${ITEM_VOL[$a]}${ITEM_PATH[$a]}"
   DU_CALL="sudo du -sc '$FULL_PATH' 2> /dev/null | tail -1 | cut -f 1"
   if [ ${ITEM_PATH[$a]} == "/System" ]; then
      DU_CALL="sudo du -sc -IVolumes '$FULL_PATH' 2> /dev/null | tail -1 | cut -f 1"
   fi

   # Ask 'du' for the size of the path
   let SIZE_SECTORS=$(eval $DU_CALL)
   let SIZE_BYTES=$SIZE_SECTORS*512
   ITEM_SIZE[$a]=$SIZE_BYTES

   # Invert number if this is a "deduct" line
   if [ ${ITEM_NEG[$a]} -eq 1 ]; then
      let ITEM_SIZE[$a]*=-1
   fi

   # Update status
   let a+=1
   printf "\e[1A\n" # erase previous "processed..." message
   PATHS_STR="paths"
   if [ $NUM_ITEMS -eq 1 ]; then
      PATHS_STR="path"
   fi
   echo -n "Getting sizes of items in set ($a/$NUM_ITEMS $PATHS_STR processed)..."
done

# Total items by type
declare -a TYPE_NAME=()
declare -a TYPE_SIZE=()
declare -a TYPE_VOL=()
LAST_TYPE="-"
a=0
b=0
while [ "x${ITEM_PATH[$a]}" != "x" ]; do
   if [ "${ITEM_TYPE[$a]}" == "$LAST_TYPE" ]; then
      let TYPE_SIZE[$(($b-1))]+=${ITEM_SIZE[$a]}
   else
      TYPE_NAME+=(${ITEM_TYPE[$a]})
      TYPE_SIZE+=(${ITEM_SIZE[$a]})
      TYPE_VOL+=(${ITEM_VOL[$a]})
      let b+=1
      LAST_TYPE=${ITEM_TYPE[$a]}
   fi

   let a+=1
done

# Print out type sizes by volume
echo;echo "==Data sizes=="
LAST_VOL="-"
DISK_TOTAL=0
GRAND_TOTAL=0
a=0
while [ "x${TYPE_NAME[$a]}" != "x" ]; do
   # Print out info for volume if we're on a new volume now
   if [ ${TYPE_VOL[$a]} != $LAST_VOL ]; then
      # Use IFS to split output from 'df' into an array
      IFS=" "
      declare -a DF_LINE=(`df "/Volumes/${TYPE_VOL[$a]}" | tail -1`)

      # Get total space of this volume
      CAPAC_BLOCKS=${DF_LINE[1]}
      let CAPAC_BYTES=$CAPAC_BLOCKS*512
      CAPAC=$(printHumanReadable $CAPAC_BYTES)

      # Get used space on this volume
      USED_BLOCKS=${DF_LINE[2]}
      let USED_BYTES=$USED_BLOCKS*512

      # Check if this is the boot volume; if so, then in macOS 10.15+ we need to add two
      # other mount points' used figures to get the total used space on the disk
      DISK_NAME=${DF_LINE[0]}
      declare -a DF_ROOT_LINE=(`df / | tail -1`)
      ROOT_VOL_NAME=${DF_ROOT_LINE[0]}
      if [ "$DISK_NAME" == "$ROOT_VOL_NAME" ]; then
         if [ -d /System/Volumes/Data ]; then
            declare -a DF_DATA_LINE=(`df /System/Volumes/Data | tail -1`)
            USED_BLOCKS=${DF_DATA_LINE[2]}
            let USED_BYTES+=$USED_BLOCKS*512
         fi
         # As of macOS 12, this directory returns the same used space as /System/Volumes/
         # Data/, incorrectly doubling the used space. Not sure when this change occurred.
         #if [ -d /private/var/vm ]; then
         #   declare -a DF_VM_LINE=(`df /private/var/vm | tail -1`)
         #   USED_BLOCKS=${DF_VM_LINE[2]}
         #   let USED_BYTES+=$USED_BLOCKS*512
         #fi
      fi

      # Convert our total used bytes to something readable
      USED=$(printHumanReadable $USED_BYTES)

      # Print total line for last volume
      if [ $LAST_VOL != "-" ]; then
         echo;echo -n "Total: "
         printHumanReadable $DISK_TOTAL
      fi

      # Print header line for this next volume
      echo "Volume: ${TYPE_VOL[$a]} ($USED/$CAPAC used)"

      # Reset stuff
      LAST_VOL=${TYPE_VOL[$a]}
      DISK_TOTAL=0
      IFS="
"
   fi

   # Print out total for data type
   echo -n "${TYPE_NAME[$a]}: "
   printHumanReadable ${TYPE_SIZE[$a]}
   echo

   DISK_TOTAL=`echo $DISK_TOTAL+${TYPE_SIZE[$a]} | bc`
   GRAND_TOTAL=`echo $GRAND_TOTAL+${TYPE_SIZE[$a]} | bc`
   
   let a+=1
done

# Print last volume's total since the "while" loop didn't get to do it
echo;echo -n "Disk total: "
printHumanReadable $DISK_TOTAL

# Print grand total for data set
echo;echo;echo -n "Grand total: "
printHumanReadable $GRAND_TOTAL
echo