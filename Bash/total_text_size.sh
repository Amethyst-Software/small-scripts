#!/bin/bash

# Count Lines by Name
# Prints the total lines in all files found by recursively
# searching for files with the specified suffix(es) in the
# supplied directory. The directory to start in is the first
# parameter and the suffixes to search for are supplied in
# regex form as the second parameter. Use "[cmh]", for
# instance, to look at all files ending in .c, .m, and .h.
# "[cx]s[d]*" would capture all .cs and .xsd files.

IFS="
"

COUNT=0
for FN in `find "$1" | grep "\.${2}$"`; do
   CUR=`cat "$FN" | wc -l`

   # Correct line count if the file does not end in a newline
   LAST_CHAR=$(tail -c -1 "$FN")
   if [ "$LAST_CHAR" != "\n" ]; then
      let CUR+=1
   fi

   let COUNT+=$CUR
done
echo $COUNT