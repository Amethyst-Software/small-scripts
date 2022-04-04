#!/bin/bash

# Scrape Smugmug Gallery
# Parameter 1: URL of a Smugmug gallery
# Parameter 2: Output directory for media
# Recommended width:
# |-----------------------------------------------------------------------------------------------------------------------|

GALLERY_PAGE="$1"
OUTPUT_DIR="$2"

AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/96.0.4664.110 Safari/537.36 OPR/82.0.4227.43"

# Safety check
if [ ! "$#" -eq 2 ]; then
   echo "You must pass this script two arguments: (1) the URL of the gallery and (2) the local path in which to save its images/video."
   exit
fi

# Get ID for RSS feed from page's HTML, if RSS is enabled; if not, quit
RSS_ID=$(curl --silent --insecure --user-agent '"$AGENT"' "$GALLERY_PAGE" | grep --max-count=1 -o "&Data=[_0-9A-Za-z]*")
RSS_ID=${RSS_ID#&Data=}
if [ -z "$RSS_ID" ]; then
   echo "The RSS feed appears to be disabled for this gallery, so it cannot be downloaded."
   exit
fi

# Construct RSS feed link by appending RSS path to gallery's domain
DOMAIN=$(echo $GALLERY_PAGE | grep -E -o "^http[s]?://([^/]+)/")
RSS_FEED="${DOMAIN}hack/feed.mg?Type=gallery&Data=$RSS_ID&ImageCount=9999&Paging=0&format=atom10"
echo "Saving images using gallery's RSS feed at $RSS_FEED..."

# Load gallery page and find thumbnail URLs, then guess full-size image URLs from those
for SUFFIX in jpg gif; do
   for IMAGE in `curl --silent --insecure --user-agent '"$AGENT"' "$RSS_FEED" | grep -o "src=\"https:.*\.$SUFFIX"`; do
      THUMB_IMG=${IMAGE#src=\"}

      # Turn thumbnail URL into largest possible image by replacing 'Th's with 'O's
      ORIG_IMG=$(echo "$THUMB_IMG" | sed "s/-Th\.${SUFFIX}$/-O.${SUFFIX}/")
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
done

# Load gallery page again and guess full-size video URLs from those provided
for MOVIE in `curl --silent --insecure --user-agent '"$AGENT"' "$RSS_FEED" | grep -o "<id>https:.*\.mp4"`; do
   MOVIE_URL=${MOVIE#<id>}

   # Two assumptions here: that 1280p is available and that 640p is what's listed (but the 640p will not download)
   HD_URL=$(echo "$MOVIE_URL" | sed "s/-640\.mp4/-1280.mp4/")
   HD_URL=$(echo "$HD_URL" | sed "s:/640/:/1280/:")

   # Replace custom domain or subdomain with canonical location of actual files
   LESS_DOMAIN=${HD_URL#*.com/}
   SWAP_DOMAIN=https://photos.smugmug.com/${LESS_DOMAIN}

   JUST_NAME=${HD_URL##*/}
   echo "Downloading $JUST_NAME..."

   curl -o "$OUTPUT_DIR/$JUST_NAME" --silent --insecure --user-agent '"$AGENT"' "$SWAP_DOMAIN"
   CURL_ERR=$(echo $?)
   if [ $CURL_ERR != 0 ]; then
      echo "Download failed with code $CURL_ERR."
   fi
done