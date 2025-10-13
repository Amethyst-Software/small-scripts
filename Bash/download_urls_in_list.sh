#!/bin/bash

# Download URLs in List
# This script calls upon 'curl' to download a list of URLs.
# Parameter 1: The path to a text file full of URLs pointing to files.
# Parameter 2: The target directory for the downloads.
# Parameter 3 (optional): The amount of seconds to sleep between downloads
# (to avoid rate limits on some sites).

SLEEP=0
if [ ! -z "$3" ]; then
   SLEEP=$3
fi

IFS="
"

if [ ! -f "$1" ]; then
   echo "Source file '$1' does not exist! Exiting."
   exit
fi

if [ ! -d "$2" ]; then
   echo "Target directory '$2' does not exist! Exiting."
   exit
fi

for URL in `cat "$1"`; do
   FILE_NAME=${URL##*/}
   echo "Downloading $FILE_NAME..."
   if [ $SLEEP > 0 ]; then
      sleep $SLEEP
   fi
   curl -L -o "$2/$FILE_NAME" --max-time 10 "$URL"
done