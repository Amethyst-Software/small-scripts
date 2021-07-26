#!/bin/bash

# Get Finder Sizes
# Uses AppleScript to ask Finder the size of the file or folder that is passed in.
# Will match what is shown in the Get Info window, except that the APFS+resource
# fork bug is not present in these results.

# Print a raw number of bytes at a human-readable scale
function printHumanReadable()
{
   if [ -z "$1" ]; then
      echo "Did not receive a number as an argument!"
      exit
   fi

   BIG_NUM=$1
   SIZE_UNIT=""
   SCALE=0
   NUM_DEC=0

   while [ $(echo $BIG_NUM'>'1000 | bc -l) -eq 1 ]; do
      BIG_NUM=$(echo | awk -v size_bytes=$BIG_NUM '{printf "%f",size_bytes/=1000}')
      let SCALE+=1
   done

   if [ $SCALE == 0 ]; then
      SIZE_UNIT="bytes"
   elif [ $SCALE == 1 ]; then
      SIZE_UNIT="KB"
   elif [ $SCALE == 2 ]; then
      SIZE_UNIT="MB"
      NUM_DEC=1
   elif [ $SCALE == 3 ]; then
      SIZE_UNIT="GB"
      NUM_DEC=2
   elif [ $SCALE == 4 ]; then
      SIZE_UNIT="TB"
      NUM_DEC=2
   else
      SIZE_UNIT="(out of scope!)"
   fi

   printf "%0.*f $SIZE_UNIT\n" $NUM_DEC $BIG_NUM
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