#!/bin/bash

# Get Hardlink Sizes
# Finds all hardlinked files on a volume or in a specified directory and prints out how
# much space the files take up and how much space is saved through the use of hardlinks.
# Note that the saving calculation can only take into account how many hardlinks were
# found to the same inode within the directory you supply; if the parent directory
# contains more hardlinks to the same inode, then the savings figure will be higher when
# the script is run on that directory.
# Parameters:

IFS="
"

# Process arguments
if [ $# -lt 2 ]; then
   echo "You need to supply '--vol [volume name]' or '--dir [path]' to this script. Additional optional arguments are '--list-files' to show each hardlink found and '--bigger-than [xX]' to filter out files equal to or below a certain size, where 'x' is a whole number and 'X' is a unit of size (allowed: k, M, G, T, P)." | fmt -w 80
   exit
fi

THE_PATH=""
BY_FILE=0
MIN_SIZE="0M"
while (( "$#" )); do
   case "$1" in
      --vol )         THE_PATH="/Volumes/$2"; shift 2;;
      --dir )         THE_PATH="$2"; shift 2;;
      --list-files )  BY_FILE=1; shift;;
      --bigger-than ) MIN_SIZE=$2; shift 2;;
      * )             echo "Unrecognized argument '$1'."; exit;;
   esac
done

if [ ! -d "$THE_PATH" ]; then
   echo "The volume or path $THE_PATH does not exist!"
   exit
fi

# Print supplied raw number of bytes at a human-readable scale
function printHumanReadable()
{
   BIG_NUM=$1
   SIZE_UNIT=""
   SCALE=0
   NUM_DEC=0

   while [ $(echo $BIG_NUM'>'1000 | bc -l) -eq 1 ]; do
      BIG_NUM=$(echo | awk -v size_bytes=$BIG_NUM '{printf "%f",size_bytes/=1000}')
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

   printf "%0.*f $SIZE_UNIT" $NUM_DEC $BIG_NUM
}

# Print findings at end of script
function printFindings()
{
   INODES_STR="inodes"
   if [ $UNIQUE_COUNT -eq 1 ]; then
      INODES_STR="inode"
   fi
   FILES_STR="files"
   if [ $ALL_COUNT -eq 1 ]; then
      FILES_STR="file"
   fi
   SAVINGS=`echo $ALL_SIZE-$UNIQUE_SIZE | bc`
   echo -ne "\nFound $UNIQUE_COUNT hardlinked $INODES_STR with "
   printHumanReadable $UNIQUE_SIZE
   echo -n " (on disk) of unique data presenting as "
   printHumanReadable $ALL_SIZE
   echo -n " (on disk) of data in $ALL_COUNT $FILES_STR, for a savings of "
   printHumanReadable $SAVINGS
   echo " within directory $THE_PATH"
}

# Gather the key data for all hardlinks into HL_DATA[]
echo "Searching for hardlinks..."
declare -a HL_DATA=()
for LINE in `sudo find -x "$THE_PATH" -type f -links +1 -size +$MIN_SIZE -ls 2> /dev/null`; do
   IFS=" "
   declare -a LINE_PARTS=($LINE)
   INODE=${LINE_PARTS[0]}
   COUNT=${LINE_PARTS[3]}
   SIZE=$((${LINE_PARTS[1]}*512))
   NAME=${LINE_PARTS[10]}
   HL_DATA+=("$INODE|$NAME|$COUNT|$SIZE")
done
echo "Finished searching for hardlinks, now collating data..."

# Sort hardlink data by inode so all hardlinks to same inode are together
IFS="
"
declare -a SORTED_HL_DATA=($(sort <<< "${HL_DATA[*]}"))

# Print hardlinks to screen, if requested, and add sizes to running totals
UNIQUE_SIZE=0
ALL_SIZE=0
UNIQUE_COUNT=0
ALL_COUNT=0
LAST_INODE=0
for LINK in ${SORTED_HL_DATA[@]}; do
   IFS="|"
   declare -a LINK_PARTS=($LINK)
   INODE=${LINK_PARTS[0]}
   NAME=${LINK_PARTS[1]}
   COUNT=${LINK_PARTS[2]}
   SIZE=${LINK_PARTS[3]}

   # If we haven't considered this inode yet, print its info and add its size to the
   # true total of unique data across all the hardlinks
   if [ $INODE != $LAST_INODE ]; then
      if [ $BY_FILE -eq 1 ]; then
         echo -e "\ninode: $INODE"
         echo -n "size: "
         printHumanReadable $SIZE
         echo " x $COUNT hardlinks (in all dir.s)"
      fi
      LAST_INODE=$INODE
      let UNIQUE_COUNT+=1
      UNIQUE_SIZE=`echo $UNIQUE_SIZE+$SIZE | bc`
   fi

   if [ $BY_FILE -eq 1 ]; then
      echo "$NAME"
   fi
   ALL_SIZE=`echo $ALL_SIZE+$SIZE | bc`
   let ALL_COUNT+=1
done

echo $(printFindings) | fmt -w 80