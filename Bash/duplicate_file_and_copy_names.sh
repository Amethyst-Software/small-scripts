#!/bin/bash

# Duplicate File and Copy Names
# Duplicates a single file and names each copy with the same name as the
# files found in a given folder. In other words, the contents of the file
# passed as $1 will be copied into folder $3 once for every file in folder
# $2, with each copy named after one of those files. The suffix of the
# duplicated files is also changed to the file extension hardcoded below.

COPYFILE="$1"
COPYNAMES="$2"
DESTFILES="$3"

for each_file in `ls "$COPYNAMES"`; do
   cp "$COPYFILE" "$DESTFILES"/${each_file%.*}.new-suffix
done