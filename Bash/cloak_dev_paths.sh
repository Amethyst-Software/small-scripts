#!/bin/bash

# Cloak Dev Paths
# When building an Xcode project, prevents full paths from your local hard
# drive becoming embedded in the binary. It does this by copying the source
# tree to a RAM disk and building it from there. You must set SYMROOT to the
# path to your source tree before running the script.
# Recommended width:
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----|

# --SAFETY--
which xcodebuild > /dev/null
if [ "$?" -ne 0 ]; then
   echo "Error: 'xcodebuild' (part of Apple's Developer Tools) does not appear to be installed, so the code cannot be built." | fmt -w 80
   exit
fi

# --CONSTANTS--
# MAXCODE_MB is an arbitrary limit as a basic safeguard to prevent runaway use
# of RAM in the event of an error; note that this is the maximum size of the
# codebase that we'll allow, but it will be multiplied by SAFETYMARGIN when
# claiming RAM for the image
MAXCODE_MB=300
let MAXCODE_SECTORS=$MAXCODE_MB*1024*2

# SAFETYMARGIN is how many times bigger the RAM disk should be than the files
SAFETYMARGIN=2

# TMPPATH will appear as the top level of the source tree in the strings in
# the binary and in debugger output, e.g. "Error 31 reported from file /tmp/
# MySourceCode/[...]/SomeSource.c"
TMPPATH=/tmp/MySourceCode

# Location of .xcworkspace or .xcodeproj below $SYMROOT/
WORKSPACEPATH="dir/containing/workspace"

# Comment out the following line if running this script through Xcode
SYMROOT=/Users/you/path/to/codebase

# --VARIABLES--
CODE_SECTORS=0
CODE_HUMANSIZE=0
SIZEUNIT=""

# --MAIN--
# Get total size of codebase, minus build/
cd ${SYMROOT}
for dir_name in srcfolder1 srcfolder2 srcfolder3 srcfolder4; do
   # Get size for this folder by reading the first word of the last line of
   # du's output
   let CODE_SECTORS+=`du -sc $dir_name | tail -1 | cut -f 1`
done

# Create human-readable version of size
if [ $CODE_SECTORS -gt 0 ]; then
   let CODE_HUMANSIZE=$CODE_SECTORS*512;

   scale=0;
   while [ $CODE_HUMANSIZE -gt 1024 ]; do
      let CODE_HUMANSIZE=$CODE_HUMANSIZE/1024
      let scale+=1
   done
   if [ $scale == 0 ]; then
      SIZEUNIT="bytes"
   elif [ $scale == 1 ]; then
      SIZEUNIT="KB"
   elif [ $scale == 2 ]; then
      SIZEUNIT="MB"
   elif [ $scale == 3 ]; then
      SIZEUNIT="GB"
   else
      SIZEUNIT="out of scope!"
   fi
fi

# Make sure the result is not zero or too big, due to some error
if [ $CODE_SECTORS == 0 ]; then
   echo "Error: Codebase size could not be obtained."
   exit 1
elif [ $CODE_SECTORS -gt $MAXCODE_SECTORS ]; then
   echo "Error: Codebase size is $CODE_SECTORS sectors ($CODE_HUMANSIZE \
$SIZEUNIT). Size limit is $MAXCODE_SECTORS sectors ($MAXCODE_MB MB). You \
can increase the limit in this script if needed."
   exit 1
else
   echo "Codebase is $CODE_HUMANSIZE $SIZEUNIT. Creating RAM disk with \
${SAFETYMARGIN}x safety margin."
fi

# Create RAM disk
if [ $SAFETYMARGIN -lt 1 ]; then
   echo "Error: Safety margin must be at least 1x."
   exit 1
fi
let CODE_SECTORS*=$SAFETYMARGIN
cloakbuild_device=`hdiutil attach -nomount ram://$CODE_SECTORS`
the_time=$(date "+%H-%M-%S")
volume_name="MySourceCode-$the_time"
newfs_hfs -v $volume_name $cloakbuild_device
if [ ! -d $TMPPATH ]; then
   mkdir $TMPPATH
fi
mount -t hfs $cloakbuild_device $TMPPATH

# Copy codebase to RAM, except build products
echo "Copying project to RAM disk..."
cd ${SYMROOT}
for dir_name in srcfolder1 srcfolder2 srcfolder3 srcfolder4; do
   cp -R $dir_name $TMPPATH
done

# Build the workspace on the RAM disk and copy the build product to the HD
cd $TMPPATH/${WORKSPACEPATH}
xcodebuild -workspace MyCode.xcworkspace -scheme "Release"
# Or, if it's a project instead...
#xcodebuild -project MyCode.xcodeproj -scheme "Release"
rm -r "${SYMROOT}/build/Release/MyApp.app"
cp -R ${TMPPATH}/build/Release/MyApp.app ${SYMROOT}/build/Release

# Unmount the RAM disk, clearing contents from $TMPPATH and memory
echo "Unmounting temp volume."
sleep 1
cd ~
diskutil unmount $TMPPATH &> /dev/null &
diskutil eject $cloakbuild_device
exit 0