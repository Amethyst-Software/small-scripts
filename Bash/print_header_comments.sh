#!/bin/bash

# Print Header Comments
# Prints the header comments that developers typically place at the tops of
# source files. Works recursively starting from the given directory.
# Intended for use in C family code. The heuristics below were hastily
# written for one-time use and are somewhat inaccurate, but they tend to err
# on the side of false positives rather than missing header comments.

# Set the field separator to a newline to avoid spaces in paths breaking our
# variable-setting
IFS="
"

# Iterate recursively through given directory's .c, .m, and .h source files
for FN in `find "$1" | grep "\.[cmh]$"`; do
   # Make sure file is not empty or nearly empty
   FILE_SIZE=`cat $FN | wc -l`
   if [ $FILE_SIZE -lt 2 ]; then
      echo "File $FN is only $FILE_SIZE lines, will not search."
      continue
   fi

   echo "--Searching in $FN...--"
   LINE_NUM=1
   IN_C_COMMENT=0
   IN_C_PLUS_COMMENT=0

   while true; do
      # Exit file if we reached end of it
      if [ $LINE_NUM -gt $FILE_SIZE ]; then
         IN_C_COMMENT=0
         IN_C_PLUS_COMMENT=0
         break
      fi

      # Get text of line
      LINE_TEXT=`tail -n+$LINE_NUM $FN | head -n1`

      # Look for start of comment block if we're not in one
      if [ $IN_C_COMMENT -eq 0 ] && [ $IN_C_PLUS_COMMENT -eq 0 ]; then
         # If we haven't hit comment header in first 10 lines, quit
         if [ $LINE_NUM -gt 10 ]; then
            break
         fi

         # Look for /* or //
         RESULT=`echo "$LINE_TEXT" | grep "/\*"`
         RESULT_CHARS=`echo -n "$RESULT" | wc -c`
         if [ $RESULT_CHARS -gt 1 ]; then
            IN_C_COMMENT=1
         else
            RESULT=`echo "$LINE_TEXT" | grep "//"`
            RESULT_CHARS=`echo -n "$RESULT" | wc -c`
            if [ $RESULT_CHARS -gt 1 ]; then
               IN_C_PLUS_COMMENT=1
            fi
         fi
      fi

      # Look for */ if we're in C comment block
      if [ $IN_C_COMMENT -eq 1 ]; then
         RESULT=`echo "$LINE_TEXT" | grep "\*/"`
         RESULT_CHARS=`echo -n "$RESULT" | wc -c`
         if [ $RESULT_CHARS -gt 1 ]; then
            IN_C_COMMENT=0
            echo "$LINE_TEXT" # we want to print the last line of a C block
            break
         fi
      fi

      # Look for end of //s if we're in C++ comment block
      if [ $IN_C_PLUS_COMMENT -eq 1 ]; then
         RESULT=`echo "$LINE_TEXT" | grep "//"`
         RESULT_CHARS=`echo -n "$RESULT" | wc -c`
         if [ $RESULT_CHARS -lt 2 ]; then
            IN_C_PLUS_COMMENT=0
            break # we don't want to print the line after a C++ block
         fi
      fi
      
      echo "$LINE_TEXT"
      let LINE_NUM+=1
   done
done