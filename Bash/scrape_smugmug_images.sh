#!/bin/bash

# Scrape Smugmug Images
# Parameter 1: URL of a Smugmug gallery
# Parameter 2: Output directory for images
# Recommended width:
# |---------------------------------------------------------------------------------------------------------------------|

GALLERY_PAGE="$1"
OUTPUT_DIR="$2"

AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_14_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/71.0.3578.98 Safari/537.36 OPR/58.0.3135.79"

# Safety check
if [ ! "$#" -eq 2 ]; then
   echo "You must pass this script two arguments: (1) the URL of the gallery and (2) the local path to save its images to."
   exit
fi

# Get ID for RSS feed from page's HTML, if RSS is enabled; if not, quit
RSS_ID=$(curl --silent --insecure --user-agent '"$AGENT"' "$GALLERY_PAGE" | grep --max-count=1 -o "&Data=[_0-9A-Za-z]*")
RSS_ID=${RSS_ID#&Data=}
if [ -z "$RSS_ID" ]; then
   echo "The RSS feed appears to be disabled for this gallery, so it cannot be downlaoded."
   exit
fi

# Construct RSS feed link by appending RSS path to gallery's domain
DOMAIN=$(echo $GALLERY_PAGE | grep -E -o "^http[s]?://([^/]+)/")
RSS_FEED="${DOMAIN}hack/feed.mg?Type=gallery&Data=$RSS_ID&ImageCount=9999&Paging=0&format=atom10"
echo "Saving images using gallery's RSS feed at $RSS_FEED..."

# Load gallery page and find thumbnail URLs, then guess full-size image URLs from those
for IMAGE in `curl --silent --insecure --user-agent '"$AGENT"' "$RSS_FEED" | grep -o "src=\"https:.*\.jpg"`; do
   THUMB_IMG=${IMAGE#src=\"}

   # Turn thumbnail URL into largest possible image by replacing 'Th's with 'O's
   ORIG_IMG=$(echo "$THUMB_IMG" | sed 's/-Th\.jpg$/-O.jpg/')
   ORIG_IMG=$(echo "$ORIG_IMG" | sed 's@/Th/@/O/@')

   JUST_ID=${ORIG_IMG##*/}
   echo "Downloading $ORIG_IMG..."

   # Call 'curl' with "-L" to follow redirects because Smugmug often redirects a call for an "O" image to something
   # like an "X3" image at a different URL
   curl -o "$OUTPUT_DIR/$JUST_ID" -L --silent --insecure --user-agent '"$AGENT"' "$ORIG_IMG"
   CURL_ERR=$(echo $?)
   if [ $CURL_ERR != 0 ]; then
      echo "Download failed with code $CURL_ERR."
   fi
done