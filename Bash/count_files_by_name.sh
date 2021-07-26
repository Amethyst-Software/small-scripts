#!/bin/bash

# Count Files by Name
# Prints the number of files found by recursively searching in the supplied
# directory for the specified suffix(es). The directory to start in is the
# first parameter and the suffixes of the source files are supplied in
# regex form as the second parameter. Use "[cmh]", for instance, to look at
# all files ending in .c, .m, and .h. "[cx]s[d]*" would capture all .cs and
# .xsd files.

IFS="
"

COUNT=0
for FN in `find "$1" | grep "\.${2}$"`; do
   let COUNT+=1
done
echo $COUNT