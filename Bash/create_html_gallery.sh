#!/bin/bash

# Create HTML Gallery
# Given a directory which contains subfolders full of images, creates an index.html in the main
# directory which lists the subfolders with links to their own index.html files, then drills down to
# each subfolder and creates an index.html with a gallery of the images in that folder. Parameters:
# '--dir PATH': The top-level folder with subfolders of images.
# '--cols NUM': How many images to place on each row of the HTML table. Specify "0" to simply list all
#     images without a table, which will cause them to wrap dynamically to the size of the window.
#     Default: 2.
# '--suff SUF': The suffix of the desired images to show in the gallery. Default: "jpg".
# '--name "MY TITLE"': The name to show at the top of your gallery and in the window title.
# '--style STYLE': Pass "light", "dark" or the path to a text file containing the contents of the
#     <style> tag which you want to be used in the HTML. Default: light.
# '--width NUM': How wide a row can get before images stop being added (overrides the chosen number
#     of columns for that row). Note that this argument invokes ImageMagick to determine the width of
#     each image, which will greatly slow down the creation of a large gallery.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---|

IFS="
"

# Check for ImageMagick
which identify > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'identify' (part of the ImageMagick suite) does not appear to be installed, so the operation cannot be performed." | fmt -w 80
   exit
fi

# Set up defaults
TOP_DIR=""
NUM_COLS=2
IMAGE_SUFFIX="jpg"
GALL_NAME="My Images"
STYLE="light"
MAX_WIDTH=0

# Opens the HTML markup and sets the page title to the first parameter passed in. The second parameter
# is the number of columns to use for the table.
function writeHTMheader()
{
   if [ "$STYLE" == "light" ]; then
      BG_COLOR="#FFFFFF"
      TEXT_COLOR="#000000"
   elif [ "$STYLE" == "dark" ]; then
      BG_COLOR="#000000"
      TEXT_COLOR="#FFFFFF"
   fi

   if [ "$2" -eq 0 ]; then
      TABLE=""
   else
      TABLE="<table>
<tr>
<td colspan=\"$2\" height=\"100\"><font size="4"><b>$1</b></font></td>
</tr>"
   fi

   if [ "$STYLE" == "light" ] || [ "$STYLE" == "dark" ]; then
      STYLE_CONTENTS="<style type=\"text/css\">
body {background-color:$BG_COLOR; color:rgb(0, 255, 191);}
.clear_font {margin-top:2px; color:$TEXT_COLOR; font-family:Arial; font-size:14px;}
.myimg {border-width:1px; border-color:#3333DD; border-style:solid;}
</style>"
   else
      STYLE_CONTENTS=$(cat "$STYLE")
   fi

   echo "<!DOCTYPE html>
<html>
<head>
<title>$1</title>
$STYLE_CONTENTS
</head>

<body class=\"clear_font\">
$TABLE"
}

# Closes the HTML markup
function writeHTMfooter()
{
   if [ "$1" -eq 0 ]; then
      TABLE=""
   else
      TABLE="</table>"
   fi

   echo "$TABLE
</body>
</html>"
}

# Process arguments
while (( "$#" )); do
   # Shift 2 spaces unless that takes us past end of argument array
   SAFE_SHIFT=2
   if [ "$#" -eq 1 ]; then
      SAFE_SHIFT=1
   fi
   case "$1" in
      --dir ) 	 TOP_DIR="$2"; shift $SAFE_SHIFT;;
      --cols )  NUM_COLS="$2"; shift $SAFE_SHIFT;;
      --suff )	 IMAGE_SUFFIX="$2"; shift $SAFE_SHIFT;;
      --name )  GALL_NAME="$2"; shift $SAFE_SHIFT;;
      --style ) STYLE="$2"; shift $SAFE_SHIFT;;
      --width ) MAX_WIDTH="$2"; shift $SAFE_SHIFT;;
      * )       echo "Unrecognized argument $1."; exit;;
   esac
done

# Check arguments received
if [ -z "$TOP_DIR" ] || [ ! -d "$TOP_DIR" ]; then
   echo "Path '$TOP_DIR' does not exist."
   exit
fi

if [[ ! "$NUM_COLS" =~ ^[0-9]+$ ]]; then
   echo "Did not receive a number for the '--cols' argument."
   exit
fi

if [ -z "$IMAGE_SUFFIX" ]; then
   echo "Did not receive an image suffix to look for."
   exit
fi

if [ -z "$GALL_NAME" ]; then
   echo "Did not receive a gallery name to use."
   exit
fi

if [ "$STYLE" != "light" ] && [ "$STYLE" != "dark" ]; then
   if [ ! -f "$STYLE" ]; then
      echo "The argument received for '--style' was not 'light', 'dark' or a file that exists."
      exit
   fi
fi

if [[ ! "$MAX_WIDTH" =~ ^[0-9]+$ ]]; then
   echo "Did not receive a number for the '--width' argument."
   exit
fi

# Start HTML table
IFS="|" # preserve newlines in output from writeHTMheader()
echo $(writeHTMheader "$GALL_NAME" 1) > "$TOP_DIR/index.html"
IFS="
"

# Get number of subfolders
SUBDIR_CT=`find -s "$TOP_DIR" -type d | wc -l | tr -d '[:space:]'`
let SUBDIR_CT-=1 # subtract "."

# Iterate through subfolders
TOP_DIR_NAME=$(basename $TOP_DIR)
DIRS_DONE=0
for SUBDIR in `find -s "$TOP_DIR" -type d`; do
   # Get number of images
   SUBDIR_FILE_CT=`find -s "$SUBDIR" -name "*.$IMAGE_SUFFIX" | wc -l | tr -d '[:space:]'`
   STR_FILES="files"
   if [ $SUBDIR_FILE_CT -eq 1 ]; then
      STR_FILES="file"
   fi

   # Skip parent folder
   SUBDIR_NAME=$(basename $SUBDIR)
   if [ $SUBDIR_NAME == $TOP_DIR_NAME ]; then
      continue
   fi

   # Update progress message
   if [ $DIRS_DONE -gt 0 ]; then
      printf "\e[1A\n"
   fi
   echo -n "Processing directory $((DIRS_DONE+1))/$SUBDIR_CT ($SUBDIR_FILE_CT $STR_FILES)..."

   # Write name of folder, followed by number of files it has, and make it link to that folder's
   # index.html
   echo "<tr><td><a href=\"$SUBDIR_NAME/index.html\">$SUBDIR_NAME/</a> ($SUBDIR_FILE_CT $STR_FILES)</td></tr>" >> "$TOP_DIR/index.html"

   # Start HTML markup in folder
   IFS="|"
   echo $(writeHTMheader "$SUBDIR_NAME" $NUM_COLS) > "$SUBDIR/index.html"
   IFS="
"

   # Add images to table
   ROW_IMGS=0
   ROW_GOAL=$NUM_COLS
   IMGS_DONE=0
   declare -a IMAGES=($(find -s "$SUBDIR" -name "*.$IMAGE_SUFFIX"))
   for ((i = 0; i < ${#IMAGES[@]}; ++i)); do
      IMAGE_NAME=$(basename ${IMAGES[$i]})

      # If new row is starting and we have a max width, calculate how many images can fit
      if [ $ROW_IMGS -eq 0 ] && [ $MAX_WIDTH -gt 0 ]; then
         CUM_WIDTH=0
         IMGS_ADDED=0
         for ((j = $i; j < ${#IMAGES[@]} && j-$i <= $ROW_GOAL; ++j)); do
            IMAGE_SIZE=$(identify -format "%[fx:w]" ${IMAGES[$j]})
            let CUM_WIDTH+=$IMAGE_SIZE
            let IMGS_ADDED+=1
            ROW_GOAL=$IMGS_ADDED
            if [ $CUM_WIDTH -gt $MAX_WIDTH ]; then
               if [ $ROW_GOAL -gt 1 ]; then
                  let ROW_GOAL-=1
               fi
               break
            fi
         done
      fi

      # If new row is starting and we are using a table, open a new <tr>
      if [ $ROW_IMGS -eq 0 ] && [ $NUM_COLS -gt 0 ]; then
         echo "<tr>" >> "$SUBDIR/index.html"
      fi

      # Add image in table cell, or without cell if table-less format was requested
      if [ $NUM_COLS -gt 0 ]; then
         echo "<td align=\"center\"><img src=\"$IMAGE_NAME\" class=\"myimg\" /></td>" >> "$SUBDIR/index.html"
      else
         echo "<img src=\"$IMAGE_NAME\" class=\"myimg\" />" >> "$SUBDIR/index.html"
      fi
      let ROW_IMGS+=1
      let IMGS_DONE+=1

      # If we're done with the row or we listed all files, close <tr>
      if [ $ROW_IMGS -eq $ROW_GOAL ] || [ $IMGS_DONE -ge $SUBDIR_FILE_CT ]; then
         echo "</tr>" >> "$SUBDIR/index.html"
         ROW_IMGS=0
      fi
   done

   # Close subfolder's HTML markup
   IFS="|"
   echo $(writeHTMfooter $NUM_COLS) >> "$SUBDIR/index.html"
   IFS="
"

   let DIRS_DONE+=1
done

# Close top-level folder's HTML markup
IFS="|"
echo $(writeHTMfooter 1) >> "$TOP_DIR/index.html"
IFS="
"
echo " done."