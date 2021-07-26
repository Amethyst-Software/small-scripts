#!/bin/bash

# Man Dump
# Dumps the man page for a given command to a text file.

if [ $# -ne 1 ]; then
   echo "mandump: You need to pass me the name of a command!"
   exit 1
fi

man $1 | col -b > "$HOME/Downloads/$1 man page.txt"