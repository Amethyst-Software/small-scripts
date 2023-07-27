#!/bin/bash

# Compare File Dates
# Compares two sets of files to make sure that all files in set 1 exist in set 2 and that no files differ
# in modification date. Note that this is a unidirectional check: set 2 is not checked for files which do
# not exist in set 1. The sets to be compared can be either directories or plain-text files which list
# specific files.
# To compare two directories, pass them with the --dirpath1 and --dirpath2 arguments. You can also name
# the directories for purposes of clearer output with the arguments --dirname1 and --dirname2. To only look
# at files with a certain suffix, pass it with --dirfilter. This argument takes just the suffix with no
# period; it is also additive; for instance, to filter for shell scripts and AppleScripts, you would pass
# the script '--dirfilter "sh" --dirfilter "scpt"'.
# To compare two lists of specific files, pass them with --listpath1 and --listpath2. As above, you can
# name the lists with --listname1 and --listname2.
# Directory comparison and list comparison are not mutually exclusive; you can pass in a set of two direc-
# tories and also a set of two file lists, and the script will compare both sets separately.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---|

IFS="
"

# Argument variables
DIR_PATH_1=""
DIR_PATH_2=""
DIR_NAME_1="directory 1"
DIR_NAME_2="directory 2"
declare -a DIR_FILTER=()
LIST_PATH_1=""
LIST_PATH_2=""
LIST_NAME_1="file list 1"
LIST_NAME_2="file list 2"

# Internal variables
DIR_FILTER_CMD=".*"
DIRS_OK=0
LISTS_OK=0
TIME_RESULT=""
FOUND_DIR_CHANGE=0
FOUND_LIST_CHANGE=0
NUM_CHANGES=0
bold=$(tput bold)
undr=$(tput smul)
norm=$(tput sgr0)

# Process arguments
while (( "$#" )); do # while we haven't shifted to the end of the args array
   case "$1" in
      --dirpath1 )  DIR_PATH_1="$2"; shift 2;;
      --dirpath2 )  DIR_PATH_2="$2"; shift 2;;
      --dirname1 )  DIR_NAME_1="$2"; shift 2;;
      --dirname2 )  DIR_NAME_2="$2"; shift 2;;
      --listpath1 ) LIST_PATH_1="$2"; shift 2;;
      --listpath2 ) LIST_PATH_2="$2"; shift 2;;
      --listname1 ) LIST_NAME_1="$2"; shift 2;;
      --listname2 ) LIST_NAME_2="$2"; shift 2;;
      --dirfilter ) DIR_FILTER+=("$2"); shift 2;;
      * )           echo "Unrecognized argument $1."; exit;;
   esac
done

# Process the dir. filters into a single string to pass to 'find'
if [ ${#DIR_FILTER[@]} -gt 0 ]; then
   DIR_FILTER_CMD="\\."
   for ((i = 0; i < ${#DIR_FILTER[@]}; ++i)); do
      if [ $i -gt 0 ]; then
         DIR_FILTER_CMD+="|"
      fi
      DIR_FILTER_CMD+="(${DIR_FILTER[$i]})"
   done
   DIR_FILTER_CMD+="$"
fi

# Perform safety checks on arguments
if [ -z "$DIR_PATH_1" ] && [ -z "$DIR_PATH_2" ] && [ -z "$LIST_PATH_1" ] && [ -z "$LIST_PATH_2" ]; then
   echo "No paths were passed into the script, so there's nothing to do! Exiting."
   exit
fi
if [ ! -z "$DIR_PATH_1" ]; then
   if [ ! -d "$DIR_PATH_1" ]; then
      echo "The path '$DIR_PATH_1' is not a directory! Exiting."
      exit
   fi
   if [ -z "$DIR_PATH_2" ]; then
      echo "Directory 1 was passed in, but not directory 2! Exiting."
      exit
   fi
fi
if [ ! -z "$DIR_PATH_2" ]; then
   if [ ! -d "$DIR_PATH_2" ]; then
      echo "The path '$DIR_PATH_2' is not a directory! Exiting."
      exit
   fi
   if [ -z "$DIR_PATH_1" ]; then
      echo "Directory 2 was passed in, but not directory 1! Exiting."
      exit
   fi
   DIRS_OK=1
fi
if [ ! -z "$LIST_PATH_1" ]; then
   if [ ! -f "$LIST_PATH_1" ]; then
      echo "The path '$LIST_PATH_1' is not a file! Exiting."
      exit
   fi
   if [ -z "$LIST_PATH_2" ]; then
      echo "File list 1 was passed in, but not file list 2! Exiting."
      exit
   fi
fi
if [ ! -z "$LIST_PATH_2" ]; then
   if [ ! -f "$LIST_PATH_2" ]; then
      echo "The path '$LIST_PATH_2' is not a file! Exiting."
      exit
   fi
   if [ -z "$LIST_PATH_1" ]; then
      echo "File list 2 was passed in, but not file list 1! Exiting."
      exit
   fi
   LISTS_OK=1
fi

# Get the modification time of a file and save it in TIME_RESULT
function getModTime()
{
   if [ ! -f "$1" ]; then
      #echo "File '$1' does not exist!"
      TIME_RESULT=-1
   else
      mod_time=$(stat -s "$1")
      mod_time=${mod_time#*st_mtime=*}
      mod_time=${mod_time%% *}

      if [ -z "$mod_time" ]; then
         echo "Failed to get mod. time of '$1'."
         exit
      fi

      TIME_RESULT=$mod_time
   fi
}

# Compare two directories
function compareDirs()
{
   echo "Directory comparison: ${undr}$DIR_NAME_1${norm} and ${undr}$DIR_NAME_2${norm}..."
   for FILE1 in `find -s "$DIR_PATH_1" -type f ! -path "*/.*"`; do
      if [[ ! "$FILE1" =~ $DIR_FILTER_CMD ]]; then
         continue
      fi
      
      getModTime "$FILE1"
      MOD_TIME1=$TIME_RESULT

      # Change the file's path string to be in FOLDER2
      FILE2=${FILE1#$DIR_PATH_1}
      FILE2=${DIR_PATH_2}${FILE2}

      getModTime "$FILE2"
      MOD_TIME2=$TIME_RESULT

      FILE_NAME=$(basename $FILE1)

      if [ $TIME_RESULT -eq -1 ]; then
         echo "${bold}$FILE_NAME${norm} has not been added to ${undr}$DIR_NAME_2${norm}."
         FOUND_DIR_CHANGE=1
         let NUM_CHANGES+=1
      elif [ $MOD_TIME1 -gt $MOD_TIME2 ]; then
         echo "${bold}$FILE_NAME${norm} is newer in ${undr}$DIR_NAME_1${norm}."
         FOUND_DIR_CHANGE=1
         let NUM_CHANGES+=1
      elif [ $MOD_TIME1 -lt $MOD_TIME2 ]; then
         echo "${bold}$FILE_NAME${norm} is newer in ${undr}$DIR_NAME_2${norm}."
         FOUND_DIR_CHANGE=1
         let NUM_CHANGES+=1
      fi
   done

   if [ $FOUND_DIR_CHANGE -eq 0 ]; then
      echo "No file differences found between directories."
   else # if there was a difference between the directories, open them so the user can work with the files
      open "$DIR_PATH_1"
      open "$DIR_PATH_2"
   fi
}

# Compare the files in two lists
function compareLists()
{
   # If DIRS_OK is true, then we printed messages before this, so add a newline to separate this output visually
   if [ $DIRS_OK -eq 1 ]; then
      echo
   fi
   
   echo "File list comparison: ${undr}$LIST_NAME_1${norm} and ${undr}$LIST_NAME_2${norm}..."
   declare -a FILE_LIST_1=($(cat "$LIST_PATH_1"))
   declare -a FILE_LIST_2=($(cat "$LIST_PATH_2"))
   SHOW_FOLDER=0
   for ((i = 0; i < ${#FILE_LIST_1[@]}; ++i)); do
      EXPANDED_PATH_1=$(eval echo ${FILE_LIST_1[$i]})
      getModTime "$EXPANDED_PATH_1"
      MOD_TIME_1=$TIME_RESULT

      EXPANDED_PATH_2=$(eval echo ${FILE_LIST_2[$i]})
      getModTime "$EXPANDED_PATH_2"
      MOD_TIME_2=$TIME_RESULT

      FILE_NAME=$(basename ${FILE_LIST_1[$i]})

      if [ $TIME_RESULT -eq -1 ]; then
         echo "${bold}$FILE_NAME${norm} has not been added to ${undr}$LIST_NAME_2${norm}."
         FOUND_LIST_CHANGE=1
         let NUM_CHANGES+=1
         SHOW_FOLDER=1
      elif [ $MOD_TIME_1 -gt $MOD_TIME_2 ]; then
         echo "${bold}$FILE_NAME${norm} is newer in ${undr}$LIST_NAME_1${norm}."
         FOUND_LIST_CHANGE=1
         let NUM_CHANGES+=1
         SHOW_FOLDER=1
      elif [ $MOD_TIME_1 -lt $MOD_TIME_2 ]; then
         echo "${bold}$FILE_NAME${norm} is newer in ${undr}$LIST_NAME_2${norm}."
         FOUND_LIST_CHANGE=1
         let NUM_CHANGES+=1
         SHOW_FOLDER=1
      fi
      
      # If there was a difference between the files, show their containing folders
      if [ $SHOW_FOLDER -eq 1 ]; then
         open "$(dirname $EXPANDED_PATH_1)"
         open "$(dirname $EXPANDED_PATH_2)"
         SHOW_FOLDER=0
      fi
   done

   if [ $FOUND_LIST_CHANGE -eq 0 ]; then
      echo "No differences found between the files in the file lists."
   fi
}

# Main portion of script
if [ $DIRS_OK -eq 1 ]; then
   compareDirs
fi

if [ $LISTS_OK -eq 1 ]; then
   compareLists
fi

STR_CHANGE="change"
if [ $NUM_CHANGES -ne 1 ]; then
   STR_CHANGE="changes"
fi
echo; echo "Found $NUM_CHANGES $STR_CHANGE."