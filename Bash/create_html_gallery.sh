#!/bin/bash

# Create HTML Gallery
# Given a directory which contains subfolders full of images, creates a master index.html in the main
# directory which lists those subfolders with links to their own index.html files, then drills down to
# each subfolder and creates an index.html with a gallery of the images in that folder.
# Requires: ImageMagick
# Known bug: Sometimes the ending </tr> in a table is not outputted. Browsers ignore this error.
# Recommended width:
# |--------------------------------------------------------------------------------------------------|

IFS="
"

# Check for ImageMagick
which identify > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'identify' (part of the ImageMagick suite) does not appear to be installed, so the operation cannot be performed." | fmt -w 80
   exit
fi

IMAGE_SUFFIX="jpg"
LARGE_IMAGE_SIZE=640
TOPDIR=$1

# Opens the HTML markup and sets page title to supplied name. The page background will be white
# unless the second parameter is '0', in which case it will be black.
function writeHTMheader()
{
   BGCOLOR="#FFFFFF"
   FONTCOLOR="#000000"
   if [ "$2" -eq 0 ]; then
      BGCOLOR="#000000"
      FONTCOLOR="#FFFFFF"
   fi

   echo "<!DOCTYPE html>
<html>
<head>
<title>Images from $1</title>

<style type=\"text/css\">
#clear_font {margin-top:2px; color:$FONTCOLOR; text-align:justify; font-family:Arial; font-size:14px;}

.myimg
{
    border-width:1px;
    border-color:#3333DD;
    border-style:solid;
}
</style>
</head>

<body bgcolor=\"$BGCOLOR\">
<span id=\"clear_font\">
<table>
<tr>
	<td colspan=\"2\" height=\"100\"><font size="4"><b>Images from $1</b></font></td>
</tr>"
}

# Closes the HTML markup
function writeHTMfooter()
{
   echo "</table>
</span>
</body>
</html>"
}

# Start HTML table
echo $(writeHTMheader "My Title" 1) > "$TOPDIR/index.html"

# Get listing of folders
TOPDIR_NAME=$(basename $TOPDIR)
for SUBDIR in `find "$1" -type d`; do
   SUBDIR_FILES=`find "$SUBDIR" -name "*.$IMAGE_SUFFIX" | wc -l | tr -d '[:space:]'`
   SUBDIR_NAME=$(basename $SUBDIR)

   # Skip parent folder
   if [ $SUBDIR_NAME == $TOPDIR_NAME ]; then
      continue
   fi

   # Write name of folder, followed by number of files it has, and make it link to that
   # folder's index.html
   echo "<tr><td><a href=\"$SUBDIR_NAME/index.html\">$SUBDIR_NAME/</a> ($SUBDIR_FILES)</td></tr>" >> "$TOPDIR/index.html"

   # Start HTML markup in folder
   echo $(writeHTMheader "$SUBDIR_NAME" 0) > "$SUBDIR/index.html"

   # Pre-scan widths of images so we know if any are large; if so, the whole gallery needs
   # to be in one column because otherwise any large image in the first column will push
   # small images in a second column off-screen
   COLUMNS=2
   for IMAGE in `find "$SUBDIR" -name "*.$IMAGE_SUFFIX"`; do
      IMAGE_SIZE=$(identify -format "%[fx:w]" $IMAGE)
      if [ $IMAGE_SIZE -gt $LARGE_IMAGE_SIZE ]; then
         COLUMNS=1
         break
      fi
   done

   IMGS_DONE=0
   for IMAGE in `find "$SUBDIR" -name "*.$IMAGE_SUFFIX"`; do
      IMAGE_NAME=$(basename $IMAGE)
      ODD_DONE=$((IMGS_DONE & 1))

      # If IMGS_DONE is even or we are using one column, open a new 'tr'
      if [ $ODD_DONE -eq 0 ] || [ $COLUMNS -eq 1 ]; then
         echo "<tr>" >> "$SUBDIR/index.html"
      fi

      # If we're starting a new row but we're on the last image, center it across both
      # columns
      COLSPAN=1
      if [ $ODD_DONE -eq 0 ] && [ $COLUMNS -eq 2 ] && [ $((IMGS_DONE + 1)) -eq $SUBDIR_FILES ]; then
         COLSPAN=2
      fi

      # Add image in table cell
      echo "<td align=\"center\" colspan=\"$COLSPAN\"><img src=\"$IMAGE_NAME\" class=\"myimg\" /></td>" >> "$SUBDIR/index.html"

      # If IMGS_DONE is odd or we are using one column, close 'tr'
      if [ $ODD_DONE -eq 1 ] || [ $COLUMNS -eq 1 ]; then
         echo "</tr>"  >> "$SUBDIR/index.html"
      fi

      let IMGS_DONE+=1
   done

   # Close folder's HTML markup
   echo $(writeHTMfooter) >> "$SUBDIR/index.html"
done

# Close HTML markup
echo $(writeHTMfooter) >> "$TOPDIR/index.html"