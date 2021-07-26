#!/bin/bash

# Find Images By Size
# Uses ImageMagick to find images of a minimum size in a given folder.
# Parameters: See error message below.
# Note: Only images with the suffixes in FIND_SUFFIXES will be looked at.
# Recommended width:
# |-------------------------------------------------------------------------------------|

IFS="
"

# Check for ImageMagick
which identify > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'identify' (part of the ImageMagick suite) does not appear to be installed, so the search cannot be performed." | fmt -w 80
   exit
fi

if [ $# -lt 4 ]; then
   echo "You must pass in these four or five parameters:
- Directory to search recursively
- Minimum width of image
- 'and' or 'or' (whether only the min. width or min. height needs to be met, or both)
- Minimum height of image
- (optional) 'port' or 'land' for portrait or landscape ratio (square images meet both)"
   exit
fi

if [ ! -d "$1" ]; then
   echo "Directory $1 not found."
   exit
fi

declare -a FIND_SUFFIXES=(jpeg jpg JPG png PNG tif tiff)

for THE_SUFFIX in "${FIND_SUFFIXES[@]}"; do
   for IMAGE in `find "$1" -name "*.$THE_SUFFIX"`; do
      # Get size of image
      IMAGE_WIDTH=$(identify -format "%[fx:w]" $IMAGE)
      IMAGE_HEIGHT=$(identify -format "%[fx:h]" $IMAGE)

      # If we couldn't read one, the other will have failed too
      if [ -z "$IMAGE_WIDTH" ]; then
         echo "Failed to read size of image $IMAGE."
         continue
      fi

      # Look at either both dimensions or just one, depending on parameter 3
      if [ "$3" == "and" ]; then
         if (( "$IMAGE_WIDTH" < $2 )) || (( "$IMAGE_HEIGHT" < $4 )); then
            continue
         fi
      elif [ "$3" == "or" ]; then
         if (( "$IMAGE_WIDTH" < $2 )); then
            continue
         fi

         if (( "$IMAGE_HEIGHT" < $4 )); then
            continue
         fi
      else
         echo "Received '$3' as third parameter; you must supply 'and' or 'or'."
         exit
      fi

      # Look at ratio of image dimensions if user asked us to
      if [ ! -z "$5" ]; then
         if [ "$5" == "port" ]; then
            if (( "$IMAGE_WIDTH" > "$IMAGE_HEIGHT" )); then
               continue
            fi
         elif [ "$5" == "land" ]; then
            if (( "$IMAGE_HEIGHT" > "$IMAGE_WIDTH" )); then
               continue
            fi
         else
            echo "Received '$5' as fifth parameter; you must supply 'port', 'land', or nothing at all."
            exit
         fi
      fi

      # If we're still here, then the image passes!
      echo "$IMAGE is ${IMAGE_WIDTH}x${IMAGE_HEIGHT}."
   done
done