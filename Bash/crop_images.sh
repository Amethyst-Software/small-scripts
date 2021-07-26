#!/bin/bash

# Crop Images
# Uses ImageMagick to create cropped copies of the images in a given folder.
# Only images with the suffixes in CROP_SUFFIXES are cropped. The five
# parameters to pass in are listed below.

IFS="
"

which convert > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'convert' (part of the ImageMagick suite) does not appear to be installed, so the conversion cannot be performed." | fmt -w 80
   exit
fi

if [ $# -ne 5 ]; then
   echo "You must pass in these five parameters for the crop operation:
target directory
width
height
x-offset for left margin of image
y-offset for top margin of image"
   exit
fi

declare -a CROP_SUFFIXES=(jpg png)

for THE_SUFFIX in "${CROP_SUFFIXES[@]}"; do
   for ORIG in `find "$1" -name "*.$THE_SUFFIX"`; do
      echo "Cropping file $ORIG..."

      # Remove ".suffix" and replace with "-crop.suffix"
      CROP=${ORIG%.$THE_SUFFIX}-crop.$THE_SUFFIX

      if [ -f "$CROP" ]; then
         echo "Can't convert this image because the name $CROP is already taken."
         continue
      fi

      convert "$ORIG" -crop ${2}x${3}+${4}+${5} "$CROP"
   done
done