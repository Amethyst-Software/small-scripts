#!/bin/bash

# Total Media Times
# Sums the times of the media files in a given folder (parameter 1) which have the suffix given in parameter 2.
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
   echo "Error: You must supply two parameters: the directory in which to look and the suffix of audio or video file to look at (without the leading period)."
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

# Round 1st param to number of decimal places given in 2nd param
round()
{
    printf '%.*f' "$2" $(echo "a=$1; if(a>0) a+=5/10^($2+1) else if (a<0) a-=5/10^($2+1); scale=$2+1; a/1" | bc)
}

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

echo -n "The total time of these $COUNT media files is $TOTAL_TIME seconds"
TOTAL_TIME_INT=$(echo $TOTAL_TIME | awk '{printf "%d",int($1)}')
if [ $TOTAL_TIME_INT -gt 60 ]; then # also give time in minutes
   MINUTES=$(echo | awk -v seconds=$TOTAL_TIME '{printf "%f",seconds/=60}')
   echo -n ", or $(round $MINUTES 1) minutes"
   
   MINUTES_INT=$(echo $MINUTES | awk '{printf "%d",int($1)}')
   if [ $MINUTES_INT -gt 60 ]; then # also give time in hours
      HOURS=$(echo | awk -v minutes=$MINUTES '{printf "%f",minutes/=60}')
      echo ", or $(round $HOURS 1) hours."
   else
      echo "."
   fi
else
   echo "."
fi