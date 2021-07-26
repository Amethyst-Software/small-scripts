#!/bin/bash

# Find List in Files
# Searches a directory of files for each term from a list,
# and outputs the lines with those terms to a file. It is
# assumed that each search term in the source list is on a
# new line.

IFS="
"

SEARCH_LOC=$1
SEARCH_NAMES=$2 # regex; the pattern "\.[ch]$" would search all files ending in ".c" or ".h"
TERM_LIST=$3

# Read a term from the list
for TERM in `cat "$TERM_LIST.txt"`; do
   # Search for files matching name pattern
   for FILE in `find "$SEARCH_LOC" | grep "$SEARCH_NAMES"`; do
      cat "$FILE" | grep "$TERM" >> "$TERM_LIST results.txt"
   done
done