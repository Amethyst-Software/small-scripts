#!/bin/bash

# Convert with FFmpeg
# Tells ffmpeg to convert all files with a given suffix to another suffix.

IFS="
"

DIR="$1"
FROM="$2"
TO="$3"

if [ -z "$1" ] || [ -z "$2" ] || [ -z "$3" ]; then
   echo "You need to pass this script three arguments: the target directory, the 'from' suffix and the 'to' suffix."
fi

if [ ! -d "$DIR" ]; then
   echo "Directory '$DIR' does not exist!"
   exit
fi

for the_file in `find -s "$DIR" -type f -name "*.$FROM"`; do
   if [ $TO == "mp3" ]; then
      ffmpeg -i "$the_file" -q:a 0 "${the_file%.$FROM}.$TO"
   else
      ffmpeg -i "$the_file" "${the_file%.$FROM}.$TO"
   fi
done