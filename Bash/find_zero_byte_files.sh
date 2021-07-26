#!/bin/bash

# Find Zero-Byte Files
# Recursively lists all files, starting from the current directory, that are zero bytes in size.

ls -ilR | egrep ^[[:digit:]]+[[:space:]]+[drwx@-]+[[:space:]]+[[:digit:]]+[[:space:]]+[[:alpha:]]+[[:space:]]+[[:alpha:]]+[[:space:]]+0