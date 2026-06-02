#!/bin/bash

# Mark Download Safe
# Remove macOS quarantine attribute from every file/folder
# in the current directory and all subdirectories.

set -e

TARGET_DIR="${1:-.}"

echo "Removing quarantine flags from: $TARGET_DIR"

# Recursively remove com.apple.quarantine extended attribute
xattr -r -d com.apple.quarantine "$TARGET_DIR" 2>/dev/null || true

# Ensure executable bits are set on files that already look executable
find "$TARGET_DIR" -type f \( -name "*.sh" -o -name "*.command" -o -perm +111 \) -exec chmod a+x {} \; 2>/dev/null || true

echo "Done."