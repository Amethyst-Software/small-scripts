#!/bin/bash

# Download With yt-dlp
# Finds the best available resolution of video (according to my
# personal preferences) for a given YouTube URL and downloads it

# Selected video format IDs (all are 16:9)
# 137 MP4 1920x1080
# 136 MP4 1280x720
# 135 MP4 854x480
# 134 MP4 640x360
# 133 MP4 426x240

IFS="
"

# The formats we want, from best to worst
declare -a MOV_FORMAT_PREFERRED=(137 136 135 134 133)
declare -a AUD_FORMAT_PREFERRED=(140)

if [ "$#" -ne 1 ]; then
   echo "You need to supply a video link to me!"
   return
fi

# Get available formats for this video
echo "Getting available formats..."
mapfile -t FORMATS_AVAILABLE < <(yt-dlp --list-formats "$1")

# Look for our preferred video codec
MOV_TO_USE=0
MATCHED=0
for MOV in "${MOV_FORMAT_PREFERRED[@]}"; do
   for FORMAT in "${FORMATS_AVAILABLE[@]}"; do
      FORMAT_ID=${FORMAT:0:3}
      if [ "$FORMAT_ID" == "$MOV" ]; then
         MOV_TO_USE=$MOV
         MATCHED=1
         break
      fi
   done
   if [ $MATCHED -eq 1 ]; then
      break
   fi
done

if [ $MATCHED -eq 0 ]; then
   echo "Could not find acceptable video ID to download!"
   exit
fi

# Look for our preferred audio codec
AUD_TO_USE=0
MATCHED=0
for AUD in "${AUD_FORMAT_PREFERRED[@]}"; do
   for FORMAT in "${FORMATS_AVAILABLE[@]}"; do
      FORMAT_ID=${FORMAT:0:3}
      if [ "$FORMAT_ID" == "$AUD" ]; then
         AUD_TO_USE=$AUD
         MATCHED=1
         break
      fi
   done
done

if [ $MATCHED -eq 0 ]; then
   echo "Could not find acceptable audio ID to download!"
   exit
fi

# Download it! Only show the percentage progress, if displayed by yt-dlp.
echo "Downloading codecs $MOV_TO_USE+$AUD_TO_USE..."
yt-dlp -f "$MOV_TO_USE"+"$AUD_TO_USE" --cookies-from-browser Opera --trim-filenames 75 -o "%(title)s.%(ext)s" "$1" 2> /dev/null | grep \%
RESULT=$?
if [ $RESULT -ne 0 ]; then
   echo "Got error $RESULT!"
fi
