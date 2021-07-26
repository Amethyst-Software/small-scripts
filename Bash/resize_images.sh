#!/bin/bash

# Resize Images
# Using ImageMagick, all images in a folder are resized to new dimensions. You can
# replace the original images or keep the resized images separate. Resizing can be
# done in pixels or as a percentage. You can also choose to only resize images of a
# certain size. Call script without arguments for usage details.

IFS="
"

# Check for ImageMagick
which identify > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'identify' (part of the ImageMagick suite) does not appear to be installed, so the conversion cannot be performed." | fmt -w 80
   exit
fi

# Variables
declare -a IMG_SUFF=(gif jpeg jpg png tiff)
FILE_MODE=0 # 1 = overwrite originals, 2 = new beside originals, 3 = new in supplied dir.
RESIZE_MODE=0 # 1 = width, 2 = height, 3 = width & height, 4 = percentage
SOURCE_WIDTH_FILTER=0
SOURCE_WIDTH_PX=0
SOURCE_WIDTH_OP=""
SOURCE_HEIGHT_FILTER=0
SOURCE_HEIGHT_PX=0
SOURCE_HEIGHT_OP=""
DEST_WIDTH=0
DEST_HEIGHT=0
DEST_PERC=0
SOURCE_DIR=""
DEST_DIR=""

# For passing output through the 'fmt' wrapping tool
function mypr()
{
   echo $1 | fmt -w 80
}

# Print help page for script
function printHelp()
{
   mypr "You must supply the following arguments:"
   mypr "'--source PATH': The directory to look in recursively for image files."
   mypr "(choose one) '--overwrite', '--beside', or '--dest PATH': The file operation mode. '--overwrite' will replace the original images with the resized ones. '--beside' will rename the original images to '[original name]-old' and place the resized images at the original images' locations. '--dest PATH' will place the resized images in the directory 'PATH', which must already exist."
   mypr "'--new-percent:NUM', or '--new-width:NUM' and/or '--new-height:NUM': The percentage to which to scale each image, or else the width and/or height to scale it to. Note that if you specify both a new width and height, the image will be squashed or stretched if the new proportions are not equal to the original proportions. If you only specify a new width or a new height, the scaling will take place proportionally."
   mypr "You may also supply these arguments:"
   mypr "(choose one width argument)"
   mypr "   '--old-width-eq:NUM': Only resize images that currently have the width 'NUM' in pixels."
   mypr "   '--old-width-lt:NUM': Only resize images that currently have a width of less than 'NUM' pixels."
   mypr "   '--old-width-le:NUM': Only resize images that currently have a width of less than or equal to 'NUM' pixels."
   mypr "   '--old-width-gt:NUM': Only resize images that currently have a width of greater than 'NUM' pixels."
   mypr "   '--old-width-ge:NUM': Only resize images that currently have a width of greater than or equal to 'NUM' pixels."
   mypr "(choose one height argument)"
   mypr "   '--old-height-eq:NUM': Only resize images that currently have the height 'NUM' in pixels."
   mypr "   '--old-height-lt:NUM': Only resize images that currently have a height of less than 'NUM' pixels."
   mypr "   '--old-height-le:NUM': Only resize images that currently have a height of less than or equal to 'NUM' pixels."
   mypr "   '--old-height-gt:NUM': Only resize images that currently have a height of greater than 'NUM' pixels."
   mypr "   '--old-height-ge:NUM': Only resize images that currently have a height of greater than or equal to 'NUM' pixels."
}

# Take apart an argument starting with "--old" or "--new" and save the user's request
function processOldNewArg()
{
   OLD_ARG=0
   if [[ $1 == --old* ]]; then
      OLD_ARG=1
   fi
   if [ $OLD_ARG -eq 1 ]; then
      if [[ $1 == *width* ]]; then
         SOURCE_WIDTH_FILTER=1
         SOURCE_WIDTH_PX=${1#*:}
         SOURCE_WIDTH_OP=${1#*--old-width}
         SOURCE_WIDTH_OP=${SOURCE_WIDTH_OP%%:*}
      elif [[ $1 == *height* ]]; then
         SOURCE_HEIGHT_FILTER=1
         SOURCE_HEIGHT_PX=${1#*:}
         SOURCE_HEIGHT_OP=${1#*--old-height}
         SOURCE_HEIGHT_OP=${SOURCE_HEIGHT_OP%%:*}
      else
         echo "Argument '$1' began with '--old' but wasn't followed by '-width' or '-height'! Exiting."
         exit
      fi
   else # "--new"
      if [[ $1 == *width* ]]; then
         DEST_WIDTH=${1#*:}
         if [ $RESIZE_MODE -eq 2 ]; then
            RESIZE_MODE=3
         else
            RESIZE_MODE=1
         fi
      elif [[ $1 == *height* ]]; then
         DEST_HEIGHT=${1#*:}
         if [ $RESIZE_MODE -eq 1 ]; then
            RESIZE_MODE=3
         else
            RESIZE_MODE=2
         fi
      elif [[ $1 == *percent* ]]; then
         DEST_PERC=${1#*:}
         RESIZE_MODE=4
      else
         echo "Argument '$1' began with '--new' but wasn't followed by '-width', '-height', or '-percent'! Exiting."
         exit
      fi
   fi
}

# Process all arguments
if [ "$#" -lt 3 ]; then
   printHelp
   exit
fi
while (( "$#" )); do
   # Shift 2 spaces unless that takes us past end of argument array, which seems to
   # hang the shell
   SAFE_SHIFT=2
   if [ "$#" -eq 1 ]; then
      SAFE_SHIFT=1
   fi

   case "$1" in
      --old* | --new* ) processOldNewArg $1; shift;;
      --source )        SOURCE_DIR="$2"; shift $SAFE_SHIFT;;
      --overwrite )     FILE_MODE=1; shift;;
      --beside )        FILE_MODE=2; shift;;
      --dest )          DEST_DIR="$2"; FILE_MODE=3; shift $SAFE_SHIFT;;
      * )               echo "Unrecognized argument '$1'. Aborting."; exit;;
   esac
done

# Sanity checks
if [ $FILE_MODE -eq 0 ]; then
   echo "You need to specify '--overwrite', '--beside', or '--dest PATH' as the file operation mode. Run this script without arguments for help."
   exit
fi

if [ $FILE_MODE -eq 3 ]; then
   if [ -z "$DEST_DIR" ]; then
      echo "You need to specify a destination path after the '--dest' argument."
      exit
   elif [ ! -d "$DEST_DIR" ]; then
      echo "You need to specify an existing directory after the '--dest' argument. Could not find '$DEST_DIR'."
      exit
   fi
fi

if [ $RESIZE_MODE -eq 0 ]; then
   echo "You need to specify '--new-percent:NUM', '--new-width:NUM', or '--new-height:NUM' as the resizing operation. Run this script without arguments for help."
   exit
fi

if [ -z $SOURCE_DIR ]; then
   echo "You need to specify a directory to search using '--source PATH'."
   exit
fi

if [ ! -d $SOURCE_DIR ]; then
   echo "The directory '$SOURCE_DIR' does not exist, so I can't search there for images!"
   exit
fi

if [ $SOURCE_WIDTH_FILTER -eq 1 ]; then
   if [ -z $SOURCE_WIDTH_PX ] || [ $SOURCE_WIDTH_PX -lt 1 ]; then
      echo "Failed to find the width you want to filter by in your '--old-width-__:NUM' argument."
      exit
   fi
   if [[ ! $SOURCE_WIDTH_OP == "-eq" ]] && [[ ! $SOURCE_WIDTH_OP == "-lt" ]] && [[ ! $SOURCE_WIDTH_OP == "-le" ]] && [[ ! $SOURCE_WIDTH_OP == "-gt" ]] && [[ ! $SOURCE_WIDTH_OP == "-ge" ]]; then
      echo "Failed to find operation '-eq', '-lt', '-le', '-gt', or '-ge' in your '--old-width-__:NUM' argument."
      exit
   fi
fi
if [ $SOURCE_HEIGHT_FILTER -eq 1 ]; then
   if [ -z $SOURCE_HEIGHT_PX ] || [ $SOURCE_HEIGHT_PX -lt 1 ]; then
      echo "Failed to find the height you want to filter by in your '--old-height-__:NUM' argument."
      exit
   fi
   if [[ ! $SOURCE_HEIGHT_OP == "-eq" ]] && [[ ! $SOURCE_HEIGHT_OP == "-lt" ]] && [[ ! $SOURCE_HEIGHT_OP == "-le" ]] && [[ ! $SOURCE_HEIGHT_OP == "-gt" ]] && [[ ! $SOURCE_HEIGHT_OP == "-ge" ]]; then
      echo "Failed to find operation '-eq', '-lt', '-le', '-gt', or '-ge' in your '--old-height-__:NUM' argument."
      exit
   fi
fi

# Main loop
for FILE_NAME in `find "$SOURCE_DIR" -type f`; do
   # If this is not a file with a name and suffix, skip it
   if [[ ! "$FILE_NAME" =~ [[:print:]]+\.[[:print:]]+$ ]]; then
      continue
   fi

   # Search for suffix in list of image suffixes
   FILE_SUFFIX=${FILE_NAME##*.}
   MATCHED=0
   shopt -s nocasematch
   for SUFFIX in "${IMG_SUFF[@]}"; do
      if [ "$SUFFIX" == $FILE_SUFFIX ]; then
         MATCHED=1
         break
      fi
   done
   shopt -u nocasematch

   # If this is not an image, then don't proceed
   if [ $MATCHED -eq 0 ]; then
      continue
   fi

   # Apply width filter if requested
   if [ $SOURCE_WIDTH_FILTER -eq 1 ]; then
      IMAGE_WIDTH=$(identify -format "%[fx:w]" $FILE_NAME)
      if [ ! $IMAGE_WIDTH $SOURCE_WIDTH_OP $SOURCE_WIDTH_PX ]; then
         continue
      fi
   fi

   # Apply height filter if requested
   if [ $SOURCE_HEIGHT_FILTER -eq 1 ]; then
      IMAGE_HEIGHT=$(identify -format "%[fx:h]" $FILE_NAME)
      if [ ! $IMAGE_HEIGHT $SOURCE_HEIGHT_OP $SOURCE_HEIGHT_PX ]; then
         continue
      fi
   fi

   # Prepare parameter to be passed to "-resize" argument
   RESIZE_ARG=""
   if [ $RESIZE_MODE -eq 1 ]; then
      RESIZE_ARG="${DEST_WIDTH}x"
   elif [ $RESIZE_MODE -eq 2 ]; then
      RESIZE_ARG="x${DEST_HEIGHT}"
   elif [ $RESIZE_MODE -eq 3 ]; then
      RESIZE_ARG="${DEST_WIDTH}x${DEST_HEIGHT}\\!"
   elif [ $RESIZE_MODE -eq 4 ]; then
      RESIZE_ARG="${DEST_PERC}%"
   fi

   # Perform resize operation
   if [ $FILE_MODE -eq 1 ]; then # "overwrite" mode
      convert "$FILE_NAME" -resize $RESIZE_ARG "$FILE_NAME"
   elif [ $FILE_MODE -eq 2 ]; then # "beside" mode
      ORIG=${FILE_NAME%.$FILE_SUFFIX}-old.$FILE_SUFFIX
      mv "$FILE_NAME" "$ORIG"
      convert "$ORIG" -resize $RESIZE_ARG "$FILE_NAME"
   elif [ $FILE_MODE -eq 3 ]; then # "new dir." mode
      # Create path in new dir. equivalent to path in orig. dir.
      REL_PATH="${FILE_NAME#$SOURCE_DIR/}"
      REL_PATH="${REL_PATH%/$(basename $FILE_NAME)}"
      mkdir -p "$(dirname $DEST_DIR/$REL_PATH)"
      convert "$FILE_NAME" -resize $RESIZE_ARG "$DEST_DIR/$REL_PATH"
   fi

   # Don't keep going if we run into an IM error
   if [ $? -ne 0 ]; then
      echo "Exiting due to ImageMagick error."
      exit
   fi
done