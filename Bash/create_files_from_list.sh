#!/bin/bash

# Create Files from List
# Makes copies of an original file once for every line in a text
# file and names the copies after the terms on those lines.

IFS="
"

BASE_FILE="$1"
NAME_LIST="$2"
DEST_PATH="$3"

for THE_TERM in `cat "$NAME_LIST"`; do
   if [ ! -f "$DEST_PATH/$THE_TERM" ]; then
      cp "$BASE_FILE" "$DEST_PATH/$THE_TERM"
   fi
done