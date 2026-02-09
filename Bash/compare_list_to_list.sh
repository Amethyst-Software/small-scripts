#!/bin/bash

# Compare List to List
# Looks for every line of File A in File B and prints the results

FILE_A="$1"
FILE_B="$2"

while IFS= read -r line
do
    if grep -F -q -- "$line" "$FILE_B"
    then
        echo "FOUND: $line"
    else
        echo "NOT FOUND: $line"
    fi
done < "$FILE_A"