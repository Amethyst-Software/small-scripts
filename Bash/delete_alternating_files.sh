#!/bin/bash

# Delete Alternating Files
# Moves to the Trash every nth file from a folder, where 'n' is either 2
# or the number specified with an argument. When deleting every other file,
# by default the 2nd, 4th, etc. file will be deleted. The starting point of
# the "every n" count can be changed with the "start from" argument, e.g. a
# "start from" argument of 5 and an 'n' of 2 would mean that the deletion
# would run: 5, 7, 9…. A "start from" of 1 and an 'n' of 3 would delete
# 1, 4, 7….

IFS="
"

START=2
N=2
DIR=""
THE_TIME=$(date "+%Y-%m-%d--%H-%M-%S")
TRASH_FOLDER="$HOME/.Trash/Deleted files ($THE_TIME)"
STR_FILES="files"

if [ $# -eq 0 ]; then
   echo "You must pass in the target directory with --dir:DIR. Two optional arguments:"
   echo "* The number of files to skip with --every-nth:N (default 2)."
   echo "* The number of the file to start deleting from with --start-from:N (default 2)."
   exit
fi

while (( "$#" )); do
   case "$1" in
      --start-from:* ) START="${1##*:}"; shift;;
      --every-nth:* )  N="${1##*:}"; shift;;
      --dir:* )        DIR="${1##*:}"; shift;;
      * )              echo "Unrecognized argument '$1'."; exit;;
   esac
done

if [ -z "$DIR" ]; then
   echo "Directory not set! You must pass the script a directory with the --dir: argument."
   exit
fi

if [ ! -d "$DIR" ]; then
   echo "'$DIR' is not a directory."
   exit
fi

if [ -z "$START" ] || [ $START -lt 1 ]; then
   echo "Received invalid argument '$START' for the starting file. Number must be positive."
   exit
fi

mkdir "$TRASH_FOLDER"
if [ ! -d "$TRASH_FOLDER" ]; then
   echo "Could not create the folder '$TRASH_FOLDER'. Aborting."
   exit
fi

NUM=0
STARTED=0
for THE_FILE in `find "$DIR" -type f ! -name ".*" | sort -V`; do
   let NUM+=1
   if [ $STARTED -eq 0 ]; then
      if [ $NUM -lt $START ]; then
         continue
      elif [ $NUM -eq $START ]; then
         STARTED=1
         NUM=0
      fi
   fi
   if [ $((NUM % N)) == 0 ]; then
      echo mv "$THE_FILE" "$TRASH_FOLDER"
   fi
done