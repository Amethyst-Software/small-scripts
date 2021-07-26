#!/bin/bash

# Convert Images
# Converts the images in the current directory from BMP to JPG using ImageMagick.

IFS="
"

which convert > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'convert' (part of the ImageMagick suite) does not appear to be installed, so the conversion cannot be performed." | fmt -w 80
   exit
fi

for ORIG in `find . -name "*.bmp"`; do
   CONV=${ORIG%.bmp}.jpg

   if [ -f "$CONV" ]; then
      echo "Can't convert this image because the name $CONV is already taken."
      continue
   fi

   convert "$ORIG" "$CONV"
done