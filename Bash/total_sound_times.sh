#!/bin/bash

# Total Sound Times
# Sums the times of the AIFFs in a folder (parameter 1). Requires ffmpeg.

IFS="
"

IN_DIR="$1"
TOTAL_TIME=0
COUNT=0

which ffprobe > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'ffprobe' (part of the ffmpeg suite) does not appear to be installed, so the operation cannot be performed." | fmt -w 80
   exit
fi

echo "Totaling the time of this folder's AIFFs..."
for AIF in `find $IN_DIR | grep .aif$ `; do
   FILENAME=$(basename "$AIF")

   # Ask ffprobe to print to variable just the duration of the file
   FILE_TIME=$(ffprobe -i "$IN_DIR/$FILENAME" -show_entries format=duration -v quiet -of csv="p=0")

   # Pass the times through 'awk' in order to add them to the running total, because these are floating-point
   # numbers and bash does not do floating-point math...
   TOTAL_TIME=$(echo | awk -v total_time=$TOTAL_TIME -v file_time=$FILE_TIME '{print total_time+=file_time}')

   let COUNT+=1
done

echo "The total time of these $COUNT audio files is $TOTAL_TIME seconds."