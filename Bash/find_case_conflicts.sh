#!/bin/bash

# Find Case Conflicts
# Prints out any items in the current directory which have names
# that would be in conflict in a non-case-sensitive file system.

find . | tr [:lower:] [:upper:] | sort | uniq -d