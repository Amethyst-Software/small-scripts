#!/bin/bash

# Collect Email Addresses
# Susses out all email addresses from the .txt files found by recursively searching the directory you
# supply in parameter 1, and saves them in a text file in the directory specified in parameter 2.
# A secondary mode is offered if you pass in "email-from" as parameter 3. In this case, only .emlx
# (Apple Mail) files will be searched for in the target directory (e.g. ~/Library/Mail/), and only the
# address of each email's sender will be collected.
# Recommended width:
# |---------------------------------------------------------------------------------------------------|

IFS="
"

SEARCH_DIR=$1

DEST_DIR=$2
THE_TIME=$(date "+%Y-%m-%d--%H-%M-%S")
DEST_FILE="$DEST_DIR/collected_addresses ($THE_TIME).txt"

COLLECT_MODE=$3

SEARCH_SUFFIX_DEFAULT=.txt$
SEARCH_SUFFIX_EMAIL=.emlx$

ADDRESS_PATTERN="[0-9a-zA-Z._-]*@[0-9a-zA-Z._-]*\.[0-9a-zA-Z._-]*"
SENDER_PATTERN="^From:.*$ADDRESS_PATTERN"

if [ ! -d "$SEARCH_DIR" ]; then
   echo "Specified search directory '$SEARCH_DIR' does not exist!"
   exit
fi

if [ ! -d "$DEST_DIR" ]; then
   echo "Specified target directory '$DEST_DIR' does not exist!"
   exit
fi

if [ ! -z "$COLLECT_MODE" ]; then
   if [ "$COLLECT_MODE" == "email-from" ]; then
      # Alternate mode: search only email files for only sender addresses
      for FN in `find "$SEARCH_DIR" | grep $SEARCH_SUFFIX_EMAIL`; do
         RESULT=$(cat "$FN" | egrep -o --max-count=1 $SENDER_PATTERN)

         # Extract just the address from the string "From: (sender name) <email address>"
         RESULT=$(echo "$RESULT" | egrep -o $ADDRESS_PATTERN)

         echo $RESULT >> "$DEST_FILE"
      done
   else
      echo "You must either specify no mode at all as the third parameter or else use 'email-from'."
      exit
   fi
else
   # Default mode: search all text files for all email addresses
   for FN in `find "$SEARCH_DIR" | grep $SEARCH_SUFFIX_DEFAULT`; do
      RESULT=$(cat "$FN" | egrep -o $ADDRESS_PATTERN)
      echo $RESULT >> "$DEST_FILE"
   done
fi