#!/bin/bash

# Print Certificate Info
# Finds all apps in supplied directory and prints the signing authority
# for each one.
# Recommended width:
# |----------------------------------------------------------------------|

if [ $# -ne 1 ]; then
  echo "You must supply a directory as an argument to this script."
  exit 1
fi

if [ ! -d "$1" ]; then
  echo "Directory not found."
  exit 1
fi

# Set the field separator to a newline to avoid spaces in paths breaking
# our variable-setting
IFS="
"

# This temp file will be deleted when the script is done
TEMP_INFO=~/Downloads/cert_info.txt

# Find all items that have ".app" at the end of their path but not
# ".app/" in the midst of their path (i.e., not .apps within .apps)
for next_item in `find "$1" | grep "\.app$" | egrep -v "\.app/"`; do
  echo "$next_item:"

  # Save stdout and stderr to file descriptors 3 and 4, then redirect
  # them to a file. If we could send this to a variable, it would be
  # great, but I can't find any way to make that work. This is only
  # necessary because 'codesign' insists on printing to stdout when
  # using normal methods of redirecting command output.
  exec 3>&1 4>&2 > "$TEMP_INFO" 2>&1

  # Get certificate info with enough detail to show the Authority lines
  codesign --display --verbose=2 "$next_item"

  # Restore stdout and stderr
  exec 1>&3 2>&4

  # Show Authority lines
  cat "$TEMP_INFO" | egrep "^Authority.*"

  # Delete temp file
  rm "$TEMP_INFO"
done