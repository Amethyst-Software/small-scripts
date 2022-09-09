#!/bin/bash

# Get Finder Sizes
# Uses AppleScript to ask Finder the size of the file or folder that is passed in.
# Should match what is shown in the Get Info window.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----|

# Print a raw number of bytes at a human-readable scale
function printHumanReadable()
{
   if [ -z "$1" ]; then
      echo "Did not receive a number as an argument!"
      exit
   fi

   BIG_NUM=$1
   SCALE=0

   while [ $(echo $BIG_NUM'>'1000 | bc -l) -eq 1 ]; do
      BIG_NUM=$(echo | awk -v size_bytes=$BIG_NUM '{printf "%f",size_bytes/=1000}')
      let SCALE+=1
   done

   # Print with precision that matches Finder's Size column
   if [ $SCALE -eq 0 ]; then
      printf "%d bytes\n" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 1 ]; then
      printf "%d KB\n" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 2 ]; then
      printf "%.1f MB\n" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 3 ]; then
      printf "%.2f GB\n" $BIG_NUM $SIZE_UNIT
   elif [ $SCALE -eq 4 ]; then
      printf "%.2f TB\n" $BIG_NUM $SIZE_UNIT
   else
      echo "Number $1 is out of scope!"
   fi
}

# Ask Finder to tell us the logical size of the item. If it's large, it will be
# returned in E-notation, so pass the result through Perl to undo this notation.
# The result for a large folder will either be instantaneous or take a long time
# to calculate, depending on whether Finder has the size cached already, so we
# place a timeout of 10 minutes on the call, which is enough for any folder
# typically found on a hard drive. Note that if we ask System Events for the
# size instead of Finder, it will (a) calculate from scratch each time we call
# the script rather than use a cache, and (b) return a 32-bit integer rather
# than a 64-bit one, at least in macOS 10.14-, causing wraparound for sizes over
# 4 GiB.
echo "Size of data is:"
RESULT=$(osascript - "${1:-.}" <<\EOF | perl -Mbignum -lpe '$_+=0,"\n"'
on run {arg}
   alias POSIX file arg
   with timeout of 600 seconds
      tell application "Finder" to get size of result
   end timeout
end run
EOF)
printHumanReadable $RESULT

# Do the same again, except ask Finder for the physical size ("size on disk")
echo "Size on disk is:"
RESULT=$(osascript - "${1:-.}" <<\EOF | perl -Mbignum -lpe '$_+=0,"\n"'
on run {arg}
   alias POSIX file arg
   with timeout of 600 seconds
      tell application "Finder" to get physical size of result
   end timeout
end run
EOF)
printHumanReadable $RESULT