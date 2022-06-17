#!/bin/bash

# Total Sound Times
# Sums the times of the audio files in a given folder (parameter 1) which have the suffix given in parameter 2.
# The suffix you supply is not case-sensitive. Requires ffmpeg.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---|

IFS="
"

IN_DIR="$1"
SUFFIX="$2"
SUFFIX_UPPER=$(echo "$SUFFIX" | tr "[:lower:]" "[:upper:]")
TOTAL_TIME=0
COUNT=0

if [ "$#" -ne 2 ]; then
   echo "Error: You must supply two parameters: the directory in which to look and the suffix of audio file to look at (without the leading period)."
   exit
fi

if [ ! -d "$IN_DIR" ]; then
   echo "Error: Directory '$IN_DIR' does not exist."
   exit
fi

which ffprobe > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'ffprobe' (part of the ffmpeg suite) does not appear to be installed, so the operation cannot be performed." | fmt -w 80
   exit
fi


echo "Totaling the time of this folder's ${SUFFIX_UPPER}s..."
for SOUND in `find $IN_DIR -iname "*.$2"`; do
   FILENAME=$(basename "$SOUND")

   # Ask ffprobe to print to variable just the duration of the file
   FILE_TIME=$(ffprobe -i "$IN_DIR/$FILENAME" -show_entries format=duration -v quiet -of csv="p=0")

   # Pass the times through 'awk' in order to add them to the running total, because these are floating-point
   # numbers and bash does not do floating-point math...
   TOTAL_TIME=$(echo | awk -v total_time=$TOTAL_TIME -v file_time=$FILE_TIME '{print total_time+=file_time}')

   let COUNT+=1
done

echo "The total time of these $COUNT audio files is $TOTAL_TIME seconds."