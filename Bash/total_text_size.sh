#!/bin/bash

# Total Text Size
# Prints the total size of all (presumably) textual files
# with the specified suffix(es) in the supplied directory.
# The directory to search recursively is the first para-
# meter and the suffixes to search for are supplied in
# regex form as the second parameter. Use "[cmh]", for
# instance, to look at all files ending in .c, .m, and .h.
# "((cs)|(xsd))" would capture all .cs and .xsd files.
# The size will be totaled in bytes, lines and words.
# The line count is more accurate than 'wc' because it
# allows for files to end without a newline.

IFS="
"

# Process arguments
if [ $# -lt 2 ]; then
   echo "You need to supply the following parameters:"
   echo "1. The directory in which to look for files."
   echo "2. The file suffix(es) to select."
   exit
fi
if [ ! -d "$1" ]; then
   echo "Directory '$1' does not exist! You need to supply a directory as the first parameter."
   exit
fi
if [ -z "$2" ]; then
   echo "You need to supply the file suffix as the second parameter, e.g. 'html'. The parameter uses regex, so if you wanted to search for more than one suffix you could use this format to find, for instance, .cs and .xsd files: '((cs)|(xsd))'."
fi

echo "Tallying files ending in '$2' in directory '$1'..."

# Process files
TOTAL_LINES=0
TOTAL_WORDS=0
TOTAL_CHARS=0
for THE_FILE in `find "$1" | egrep "\.${2}$"`; do
   RESULT=`wc "$THE_FILE"`
   
   # Break up line which is in format "lines words chars file_name"
   IFS=" "
   declare -a LINE_PARTS=($RESULT)
   CUR_LINES=${LINE_PARTS[0]}
   CUR_WORDS=${LINE_PARTS[1]}
   CUR_CHARS=${LINE_PARTS[2]}

   # Correct the line count obtained if the file does not end in a newline
   LAST_CHAR=$(tail -c -1 "$THE_FILE")
   if [ "$LAST_CHAR" != "\n" ]; then
      let CUR_LINES+=1
   fi

   let TOTAL_LINES+=$CUR_LINES
   let TOTAL_WORDS+=$CUR_WORDS
   let TOTAL_CHARS+=$CUR_CHARS
done

# Print results
echo "Totals:"
echo "LINE: $TOTAL_LINES"
echo "WORD: $TOTAL_WORDS"
echo "CHAR: $TOTAL_CHARS"