#!/bin/bash

# HTTP Tests
# Prints a specified type of response to an HTTP query on a specified URL.
# Parameter 1: Desired type of response to obtain. Allowed types are:
#    "response": HTTP response code (status)
#    "header": HTTP header
#    "redirect": Redirect URL returned for this URL
#    "archive": Internet Archive response code (whether this page is archived)
#    "source": Full page source
# Parameter 2: The URL to test.
# Recommended width:
# |--------------------------------------------------------------------------------------------------------------------------|

IFS="
"

if [ "$#" -ne 2 ]; then
   echo "You need to supply two parameters: a mode argument (\"response\", \"header\", \"redirect\", \"archive\", or \"source\") and then a URL to test."
   exit 1
fi

AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_3) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.122 Safari/537.36 OPR/67.0.3575.53"
URL=$2

if [ "$1" == "response" ]; then
   curl -o /dev/null --silent --insecure --compressed --head --user-agent '$AGENT' --write-out '%{http_code}\n' $URL
elif [ "$1" == "header" ]; then
   curl --silent --insecure --compressed --head --user-agent '$AGENT' $URL
elif [ "$1" == "redirect" ]; then
   curl -o /dev/null --silent --insecure --compressed --head --user-agent '$AGENT' --max-time 10 --write-out '%{redirect_url}\n' $URL
elif [ "$1" == "archive" ]; then
   curl --silent --max-time 10 "http://archive.org/wayback/available?url=$URL&statuscodes=200&statuscodes=203&statuscodes=206"
   echo
elif [ "$1" == "source" ]; then
   curl --silent --insecure --user-agent '$AGENT' $URL
else
   echo "Invalid mode argument '$1'. Aborting."
fi