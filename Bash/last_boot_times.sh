#!/bin/bash

# Last Boot Times
# Lists the last date that every currently-mounted volume was booted from.

# Set the field separator to a newline to avoid spaces in disk names breaking
# our variable-setting
IFS="
"

MACFILE=private/var/log/system.log
WINFILE=Windows/bootstat.dat

for DISK in `ls -A /Volumes`; do
   echo "Considering $DISK..."
   if [ -f "/Volumes/$DISK/$MACFILE" ]; then
      BOOTFILE=$MACFILE
   elif [ -f "/Volumes/$DISK/$WINFILE" ]; then
      BOOTFILE=$WINFILE
   else
      echo "Not a bootable drive."
      continue
   fi

   IFS=" "
   WORD_CTR=0
   echo -n "Last booted: "
   for WORD in `ls -lT "/Volumes/$DISK/$BOOTFILE"`; do
      let WORD_CTR+=1
      if [ $WORD_CTR -eq 6 ] || [ $WORD_CTR -eq 7 ]; then
         echo -n "$WORD "
      elif [ $WORD_CTR -eq 9 ]; then
         echo $WORD
      fi
   done
done