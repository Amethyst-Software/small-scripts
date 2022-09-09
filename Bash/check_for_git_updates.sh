#!/bin/bash

# Check for Git Updates
# Instead of using 'git pull' to blindly pull whatever commits are upstream of
# your working copy, this script lets you check in advance whether there are
# any commits to pull. Pass in the working copy's directory as the sole
# argument.

ORIG_DIR=$(dirname "$0")
cd "$1"

git remote update

HEAD_SHA=$(git rev-parse HEAD)
UPSTR_SHA=$(git rev-parse @{u})

if [ "$HEAD_SHA" != "$UPSTR_SHA" ]; then
   echo "There are updates upstream! Run 'git pull'? (y/N)"

   read the_answer

   if [ "$the_answer" == "y" ]; then
      git pull
   else
      echo "No updates pulled."
   fi
else
   echo "No updates available."
fi

cd "$ORIG_DIR"