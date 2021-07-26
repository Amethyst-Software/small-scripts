#!/bin/bash

# Rename Emails with Dates
# Changes the name of an email to be its date, since the usual name, e.g. 18642.emlx,
# is hardly useful, and this allows us to sort a folder of emails by their dates when
# the original timestamp of the files is not accurate. To avoid serious malfunctions,
# copies of the emails are renamed, not the originals. Pass in the folder with the
# emails as parameter 1, and the path to a folder that can hold the renamed copies of
# the emails as parameter 2. Note that this script performs a "flat copy", placing all
# emails into the destination folder side by side. If two emails have the same
# timestamp, the name conflict will be resolved by adding a number to the name.
# Special notes:
# - If the script encounters an email that it absolutely can't read the date of, it
# will exit at that point and show you the email. You can inspect the email manually
# and either teach the script that email's date format or, if it's a corrupted file,
# you can add its name (no suffix necessary) to SKIP_FILES, and the next time the
# script runs, it will pass over that failed file.
# - If you pass in "--dry-run" as the third or fourth parameter, the script will not
# actually copy anything. This is useful for making sure in advance that nothing will
# be left behind when you attempt to copy and rename all emails from the source
# directory.
# - If you pass in "--stop-on-fail" as the third or fourth parameter, the script will
# stop when it reaches a file in which it cannot find a date, and show you that file in
# the Finder.
# Recommended width:
# |-----------------------------------------------------------------------------------|

# Set the field separator to a newline to avoid spaces in paths breaking our
# variable-setting
IFS="
"

## VARIABLES ##
SEARCH_PATH="$1"
DEST_PATH="$2"
DRY_RUN=0
TOTAL_FILES=0
COPIED=0
STOP_AND_SHOW=0
declare -a SKIP_FILES=("17332" "17133" "17134" "17135" "20889" "16118")
SKIPPED=0
PROB_FOLDER="$DEST_PATH/ Problem files"
PROBLEMS_FOUND=0
PROBLEMS_COPIED=0
STR_FILES="files"

## ARGUMENT PROCESSING ##
if [ $# -lt 2 ] || [ $# -gt 4 ]; then
   echo "You need to supply the directory with emails in it and the directory to copy the renamed emails to. Optional parameter '--dry-run' will only scan all files and not copy anything. Optional parameter '--stop-on-fail' will stop the script when a problem file is encountered and show you the file. These parameters can be used together or separately."
   exit
fi

if [ ! -d "$SEARCH_PATH" ]; then
   echo "Search directory $SEARCH_PATH does not exist!"
   exit
fi

if [ ! -d "$DEST_PATH" ]; then
   echo "Destination directory $DEST_PATH does not exist!"
   exit
fi

case "$3" in
   --dry-run )      DRY_RUN=1;;
   --stop-on-fail ) STOP_AND_SHOW=1;;
   "" )             ;;
   * )              echo "Unrecognized argument '$3'."; exit;;
esac

case "$4" in
   --dry-run )      DRY_RUN=1;;
   --stop-on-fail ) STOP_AND_SHOW=1;;
   "" )             ;;
   * )              echo "Unrecognized argument '$4'."; exit;;
esac

# Checks to see if file name passed in is taken; if so, it attempts to add a number to
# the file name, and passes back the first available path that is found; function will
# exit script if no available path is found
function correctForPathConflict()
{
   isFile=

   if ! [ -a "$1" ]; then
      echo "$1"
      return
   elif [ -f "$1" ]; then
      isFile=true
   elif [ -d "$1" ]; then
      isFile=false
   else
      echo "Error: Encountered something that is not a file or directory: $1."
      exit 56
   fi

   ct=0
   TEST_PATH="$1"
   until [ $ct -eq 3000 ]; do
      if [ -a "$TEST_PATH" ]; then
         let ct+=1
         # If this is a file, and it has a suffix, break the name up at the period so
         # we can insert the unique number at the end of the name and not the suffix
         if $isFile && [[ $1 == *.* ]]; then
            preDot=${1%.*}
            postDot=${1##*.}
            TEST_PATH="$preDot $ct.$postDot"
         else
            TEST_PATH="$1 $ct"
         fi
      else
         break
      fi
   done
   if [ $ct -eq 3000 ]; then
      # Just quit, because something is probably wrong
      echo "Error: Cannot find a place in $(dirname $1) for $(basename $1)."
      exit 57
   else
      echo "$TEST_PATH"
   fi
}

# Checks to see if file name passed in matches our manual list of files to skip. If
# not, either shows the file in the Finder or copies it to a "problem" folder.
function handleFailure()
{
   let PROBLEMS_FOUND+=1
   FILE_NAME=$(echo "$1" | sed 's/.*\///') # clip file name from whole path
   a=0
   while [ "x${SKIP_FILES[$a]}" != "x" ]; do
      if [[ "$FILE_NAME" =~ ^${SKIP_FILES[$a]}.* ]]; then
         echo "This file is in our skip list. Skipping…"
         let SKIPPED+=1
         return
      fi
      let a+=1
   done

   echo -n "This file is not in our skip list. "
   if [ $STOP_AND_SHOW -eq 1 ]; then
      echo "Showing in Finder…"
      open -R "$1"
      exit
   else
      DESIRED_PATH="$PROB_FOLDER/$FILE_NAME"
      CORRECTED_PATH=$(correctForPathConflict "$DESIRED_PATH")
      if [ $DRY_RUN -eq 0 ]; then
         echo "Copying to ' Problem files' folder…"
         mkdir -p "$PROB_FOLDER"
         cp -a "$1" "$CORRECTED_PATH"
         let PROBLEMS_COPIED+=1
      else
         echo
      fi
   fi
}

## MAIN SCRIPT ##
TOTAL_FILES=$(find "$SEARCH_PATH" | grep ".emlx$" | wc -l | tr -d '[:space:]')
for THE_FILE in `find "$SEARCH_PATH" | grep ".emlx$"`; do
   # Extract "Date:" line from top of email and narrow down to just the actual date
   DATE_LINE=`grep --max-count=1 "^Date:" "$THE_FILE"`
   JUST_DATE=${DATE_LINE#Date: }

   # If we didn't find a "Date:" line, then look for one other known line with a date
   if [ -z $DATE_LINE ]; then
      DATE_LINE=`grep --max-count=1 "^X-Apparently-To:" "$THE_FILE"`
      JUST_DATE=${DATE_LINE#*; }
   fi

   if [ -z $DATE_LINE ]; then
      echo "Could not find date line in file $THE_FILE."
      handleFailure $THE_FILE
      continue
   fi

   # Convert date string to a format that is safe for the file system. If the
   # conversion fails, try another format of date string encountered in emails.
   SAFE_DATE=

   # Try expected format "Day, dd Month yyyy hh:mm:ss +/-dst_offset"
   if [ -z $SAFE_DATE ]; then
      SAFE_DATE=`date -j -f "%a, %d %b %Y %H:%M:%S %z" $JUST_DATE "+%Y-%m-%d--%H-%M-%S" 2>/dev/null`
   fi

   # Try expected format "Day, dd Month yyyy hh:mm:ss time_zone_name"
   if [ -z $SAFE_DATE ]; then
      SAFE_DATE=`date -j -f "%a, %d %b %Y %H:%M:%S %Z" $JUST_DATE "+%Y-%m-%d--%H-%M-%S" 2>/dev/null`
   fi

   # Try expected format "dd Month yyyy hh:mm:ss +/-dst_offset"
   if [ -z $SAFE_DATE ]; then
      SAFE_DATE=`date -j -f "%d %b %Y %H:%M:%S %z" $JUST_DATE "+%Y-%m-%d--%H-%M-%S" 2>/dev/null`
   fi

   # Try expected format "Day, dd Month yyyy" (time is on a second line)
   if [ -z $SAFE_DATE ]; then
      SAFE_DATE=`date -j -f "%a, %d %b %Y" $JUST_DATE "+%Y-%m-%d--12-00-00" 2>/dev/null`
   fi

   if [ -z $SAFE_DATE ]; then
      echo "Could not understand format of date line '$DATE_LINE' in file $THE_FILE."
      handleFailure $THE_FILE
      continue
   fi

   DESIRED_PATH="$DEST_PATH/$SAFE_DATE.emlx"
   CORRECTED_PATH=$(correctForPathConflict "$DESIRED_PATH")
   if [ $DRY_RUN -eq 0 ]; then
      cp -a "$THE_FILE" "$CORRECTED_PATH"
   fi
   let COPIED+=1
done

if [ $COPIED -eq 1 ]; then
   STR_FILES="file"
fi

if [ $DRY_RUN -eq 0 ]; then
   echo -n "Copied and renamed $COPIED $STR_FILES. "
else
   echo -n "Successfully read $COPIED $STR_FILES. "
fi

echo "Encountered $PROBLEMS_FOUND problem files, $SKIPPED of which were on our skip list and $PROBLEMS_COPIED of which were copied to the ' Problem files' folder inside the destination folder."