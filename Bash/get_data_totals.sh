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
# |--------------------------------------------------------------------------------------|

IFS="
"

# Sanity check
if [ $# -ne 2 ]; then
   echo "You need to supply the arguments '--dir path/to/dir' for the directory to get the size of, or else '--file path/to/file' to specify a text file with a list of paths to get the sizes of. Read the comment at the top of this script to learn how to format the text file."
   exit
fi

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

# Init global variables
declare -a VOL_NAMES=() # parallel array with next four
declare -a DATA_TYPES=()
declare -a DIR_PATHS=()
declare -a DATA_SIZES=()
declare -a DEDUCT_IT=()
NUM_PATHS=0

# Print a raw number of bytes at a human-readable scale
function printHumanReadable()
{
   if [ -z "$1" ]; then
      echo "Did not receive a number as an argument!"
      exit
   fi

   BIG_NUM=$1
   SIZE_UNIT=""
   SCALE=0
   NUM_DEC=0

   while [ $(echo $BIG_NUM'>'1000 | bc -l) -eq 1 ]; do
      BIG_NUM=$(echo | awk -v size_bytes=$BIG_NUM '{printf "%f",size_bytes/=1000}')
      let SCALE+=1
   done

   if [ $SCALE -eq 0 ]; then
      SIZE_UNIT="bytes"
   elif [ $SCALE -eq 1 ]; then
      SIZE_UNIT="KB"
   elif [ $SCALE -eq 2 ]; then
      SIZE_UNIT="MB"
      NUM_DEC=1
   elif [ $SCALE -eq 3 ]; then
      SIZE_UNIT="GB"
      NUM_DEC=2
   elif [ $SCALE -eq 4 ]; then
      SIZE_UNIT="TB"
      NUM_DEC=2
   else
      echo "Number $1 is out of scope!"
      SIZE_UNIT="??"
   fi

   printf "%0.*f $SIZE_UNIT" $NUM_DEC $BIG_NUM
}

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
      continue
   fi

   # If this line is a data type, read it in
   if [[ $THE_LINE =~ ^type=[[:print:]]+$ ]]; then
      CUR_TYPE=${THE_LINE##type=}
      continue
   fi

   # If this line is asking to be deducted from the total, set the "deduct" flag and
   # remove the '-' from the beginning
   if [[ $THE_LINE =~ ^- ]]; then
      THE_LINE=${THE_LINE#-}
      DEDUCT_IT+=(1)
   else
      DEDUCT_IT+=(0)
   fi

   # Otherwise this must be a directory path, so read it in, invoking 'eval' in order to
   # expand shortcuts like '~' or "$HOME", then make sure it exists
   THE_PATH="$(eval echo "$THE_LINE")"
   FULL_PATH="/Volumes/$CUR_VOL$THE_PATH"
   if [ ! -d "$FULL_PATH" ]; then
      echo "Error: $THE_PATH does not exist on volume $CUR_VOL."
      continue
   fi

   # Store the path and its metadata (data sizes to be determined later)
   DIR_PATHS+=($THE_PATH)
   VOL_NAMES+=($CUR_VOL)
   DATA_TYPES+=($CUR_TYPE)
   DATA_SIZES+=(0)
   let NUM_PATHS+=1
done

# Iterate over paths, filling in size metadata
a=0
echo -n "Getting sizes of directories ($a/$NUM_PATHS paths processed)..."
while [ "x${DIR_PATHS[$a]}" != "x" ]; do
   # If 'du' is being asked to get the size of /System, mask out the subdir "Volumes"
   # since this is a link in Catalina to the entire volume
   FULL_PATH="/Volumes/${VOL_NAMES[$a]}${DIR_PATHS[$a]}"
   DU_CALL="sudo du -sc '$FULL_PATH' 2> /dev/null | tail -1 | cut -f 1"
   if [ "${DIR_PATHS[$a]}" == "/System" ]; then
      DU_CALL="sudo du -sc -IVolumes '$FULL_PATH' 2> /dev/null | tail -1 | cut -f 1"
   fi

   # Ask 'du' for the size of the path
   let SIZE_SECTORS=$(eval $DU_CALL)
   let SIZE_BYTES=$SIZE_SECTORS*512
   DATA_SIZES[$a]=$SIZE_BYTES

   # Invert number if this is a "deduct" line
   if [ ${DEDUCT_IT[$a]} -eq 1 ]; then
      let DATA_SIZES[$a]*=-1
   fi

   # Update status
   let a+=1
   printf "\e[1A\n" # erase previous "processed..." message
   PATHS_STR="paths"
   if [ $NUM_PATHS -eq 1 ]; then
      PATHS_STR="path"
   fi
   echo -n "Getting sizes of directories ($a/$NUM_PATHS $PATHS_STR processed)..."
done

# Print out list of sizes
echo -ne "\n\n==Data sizes=="
LAST_VOL="-"
LAST_TYPE="-"
TYPE_TOTAL=0
DISK_TOTAL=0
GRAND_TOTAL=0
a=0
while [ "x${DIR_PATHS[$a]}" != "x" ]; do
   # Print out info for volume if we're on a new volume now
   if [ ${VOL_NAMES[$a]} != $LAST_VOL ]; then
      # Use IFS to split output from 'df' into an array
      IFS=" "
      declare -a DF_LINE=(`df "/Volumes/${VOL_NAMES[$a]}" | tail -1`)

      # Get total space of this volume
      CAPAC_BLOCKS=${DF_LINE[1]}
      let CAPAC_BYTES=$CAPAC_BLOCKS*512
      CAPAC=$(printHumanReadable $CAPAC_BYTES)

      # Get used space on this volume
      USED_BLOCKS=${DF_LINE[2]}
      let USED_BYTES=$USED_BLOCKS*512

      # Check if this is the boot volume; if so, then in Catalina we need to add two
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
         if [ -d /private/var/vm ]; then
            declare -a DF_VM_LINE=(`df /private/var/vm | tail -1`)
            USED_BLOCKS=${DF_VM_LINE[2]}
            let USED_BYTES+=$USED_BLOCKS*512
         fi
      fi

      # Convert our total used bytes to something readable
      USED=$(printHumanReadable $USED_BYTES)

      # Print total line for last volume
      if [ $LAST_VOL != "-" ]; then
         echo -ne "\nTotal: "
         printHumanReadable $DISK_TOTAL
      fi

      # Print header line for this next volume
      if [ $LAST_VOL != "-" ]; then
         echo -ne "\n\n"
      else
         echo -ne "\n"
      fi
      echo -ne "Volume: ${VOL_NAMES[$a]} ($USED/$CAPAC used)"

      # Reset stuff
      LAST_VOL=${VOL_NAMES[$a]}
      DISK_TOTAL=0
      IFS="
"
   fi

   # Print out total for data type if we're done with it, otherwise just add to the
   # running total
   if [ ${DATA_TYPES[$a]} != $LAST_TYPE ]; then
      TYPE_TOTAL=${DATA_SIZES[$a]}
      LAST_TYPE=${DATA_TYPES[$a]}
      echo
   else
      TYPE_TOTAL=`echo $TYPE_TOTAL+${DATA_SIZES[$a]} | bc`
   fi

   DISK_TOTAL=`echo $DISK_TOTAL+${DATA_SIZES[$a]} | bc`
   GRAND_TOTAL=`echo $GRAND_TOTAL+${DATA_SIZES[$a]} | bc`

   printf "\e[1A\n" # erase previous total for this type
   echo -n "$LAST_TYPE: "
   printHumanReadable $TYPE_TOTAL
   
   let a+=1
done

# Print last volume's total since the "while" loop didn't get to do it
echo -ne "\nTotal: "
printHumanReadable $DISK_TOTAL

# Print grand total for data set
echo -ne "\n\nGrand total: "
printHumanReadable $GRAND_TOTAL
echo