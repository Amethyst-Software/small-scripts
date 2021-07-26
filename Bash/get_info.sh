#!/bin/bash

# Get Info
# Tells you the size on disk and the item count of a directory, similar to the
# Finder's Get Info window. See notes below; this script was written to my personal
# specifications and might need modification to give you the results you want.
#
# Notes on size reporting:
# - Turn on PRINT_BIN_SIZES to get the size in binary units (KiB, MiB, etc.) in
# addition to decimal units (ISO-standard KB, MB, etc.).
# - The Finder's List view and Get Info window primarily display "logical size", not
# "physical size" (size on disk). This script calculates physical sizes, so there
# will seem to be a mismatch, but the script's decimal size should match the Get Info
# window's "on disk" stat.
#
# Notes on item reporting:
# - The script deliberately does not count folders, only files and packages, unlike
# the Get Info window.
# - The script deliberately omits counting invisible files in a directory. This will
# cause a mismatch with the Get Info window's item count due to files like .DS_Store.
# - An attempt is made to treat packages as single items wherever the Finder does,
# however the Finder is not consistent in its treatment of packages, sometimes
# presenting and handling them as folders (for example, .framework), so this will
# also cause a mismatch in item count.

# Set the field separator to a newline to avoid spaces in paths breaking our variable-setting later
IFS="
"

# Safety checks
if [ $# -ne 1 ]; then
   echo "You need to pass this command the path to a directory. Exiting."
   exit
fi

if [ ! -d "$1" ]; then
   echo "Specified path $1 is not a folder! Exiting."
   exit
fi

# Init constants
TEMP_DIR=$(mktemp -d)
DIR_LIST="$TEMP_DIR/gi_dirlist.txt"
SIZE_LIST="$TEMP_DIR/gi_sizelist.txt"
COUNT_LIST="$TEMP_DIR/gi_countlist.txt"
PRINT_BIN_SIZES=1

# Save full recursive contents of this dir.
sudo find "$1" -ls > "$DIR_LIST"

# Filter out directories and save list of only files (for calculating size)
egrep -v "^[[:space:]]*([^[:space:]]+[[:space:]]+){2}d" "$DIR_LIST" > "$SIZE_LIST"

# Save list of only visible files (for counting items)
egrep -v "^[[:space:]]*([^[:space:]]+[[:space:]]+){2}d|/\.|\.$|Desktop DB|Desktop DF|/Icon\>|/[^/]+\.\w+/" "$DIR_LIST" > "$COUNT_LIST"

# Add packages themselves to list of visible items
egrep "^[[:space:]]*([^[:space:]]+[[:space:]]+){2}d" "$DIR_LIST" | egrep -v "\w+\.\w+/" | egrep "\.\w+$" >> "$COUNT_LIST"

# Get item count
THE_COUNT=$(cat "$COUNT_LIST" | wc -l | tr -d '[:space:]')

# Tally file sizes
TOTAL_SECTORS=0
for THE_LINE in `cat "$SIZE_LIST"`; do
   # Sum the second column in 'ls' output (file size in 512-byte blocks)
   IFS=" "
   declare -a LINE_WORDS=($THE_LINE)
   IFS="
"
   let TOTAL_SECTORS+=LINE_WORDS[1]
done

# Create human-readable versions of size
SIZE_DEC_UNIT="bytes"
SIZE_BIN_UNIT="bytes"
if [ $TOTAL_SECTORS -gt 0 ]; then
   let TOTAL_BYTES=$TOTAL_SECTORS*512;
   SIZE_DEC_INT=$TOTAL_BYTES
   SIZE_DEC_FLT=$SIZE_DEC_INT
   SIZE_BIN_INT=$TOTAL_BYTES
   SIZE_BIN_FLT=$SIZE_BIN_INT

   scale=0;
   while [ $SIZE_DEC_INT -gt 1000 ]; do
      SIZE_DEC_FLT=$(echo | awk -v size_dec=$SIZE_DEC_FLT '{print size_dec/=1000}')
      SIZE_DEC_INT=$(echo | awk -v size_dec=$SIZE_DEC_FLT '{print int(size_dec)}')
      let scale+=1
   done
   if [ $scale == 0 ]; then
      SIZE_DEC_UNIT="bytes"
   elif [ $scale == 1 ]; then
      SIZE_DEC_UNIT="KB"
   elif [ $scale == 2 ]; then
      SIZE_DEC_UNIT="MB"
   elif [ $scale == 3 ]; then
      SIZE_DEC_UNIT="GB"
   elif [ $scale == 4 ]; then
      SIZE_DEC_UNIT="TB"
   else
      SIZE_DEC_UNIT="(out of scope!)"
   fi

   if [ $PRINT_BIN_SIZES == 1 ]; then
   scale=0;
   while [ $SIZE_BIN_INT -gt 1024 ]; do
      SIZE_BIN_FLT=$(echo | awk -v size_bin=$SIZE_BIN_FLT '{print size_bin/=1024}')
      SIZE_BIN_INT=$(echo | awk -v size_bin=$SIZE_BIN_FLT '{print int(size_bin)}')
      let scale+=1
   done
   if [ $scale == 0 ]; then
      SIZE_BIN_UNIT="bytes"
   elif [ $scale == 1 ]; then
      SIZE_BIN_UNIT="KiB"
   elif [ $scale == 2 ]; then
      SIZE_BIN_UNIT="MiB"
   elif [ $scale == 3 ]; then
      SIZE_BIN_UNIT="GiB"
   elif [ $scale == 4 ]; then
      SIZE_BIN_UNIT="TiB"
   else
      SIZE_BIN_UNIT="(out of scope!)"
   fi
   fi
fi

# Round sizes to hundredths place
SIZE_DEC_FLT=$(printf "%0.2f" $SIZE_DEC_FLT)
SIZE_BIN_FLT=$(printf "%0.2f" $SIZE_BIN_FLT)

# Present the results
echo "The folder contains:"
if [ $PRINT_BIN_SIZES == 1 ]; then
   echo "$SIZE_DEC_FLT $SIZE_DEC_UNIT ($SIZE_BIN_FLT $SIZE_BIN_UNIT),"
else
   echo "$SIZE_DEC_FLT $SIZE_DEC_UNIT,"
fi
STR_ITEMS="items"
if [ $THE_COUNT == 1 ]; then
   STR_ITEMS="item"
fi
echo "$THE_COUNT $STR_ITEMS."