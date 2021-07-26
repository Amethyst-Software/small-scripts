#!/bin/bash

# ZipSafe
# Zips up folders without the Mac's .DS_Stores that become visible in Windows.
# It also omits .svn and .git folders to avoid distributing dev-related files.

if [ $# -ne 1 ]; then
	echo "Please pass the script a directory to be zipped."
	exit
fi

TO_ZIP=$1
TZ_FOLDER=$(basename "$TO_ZIP")

if [ ! -d "$TO_ZIP" ]; then
	echo "Directory passed in does not exist!"
	exit
fi

cd "$TO_ZIP"
zip -ry ../"$TZ_FOLDER".zip ./* -x \*.DS_Store \*.svn/* \*.git/*
cd ..