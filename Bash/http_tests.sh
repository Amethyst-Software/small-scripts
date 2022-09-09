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
# |---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ---- ----|

IFS="
"

if [ "$#" -ne 2 ]; then
   echo "You need to supply two parameters: a mode argument (\"response\", \"header\", \"redirect\", \"archive\", or \"source\") and then a URL to test."
   exit 1
fi

AGENT="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.5060.134 Safari/537.36"
OPT=$1
URL=$2

if [ "$OPT" == "response" ]; then
   curl -o /dev/null --silent --insecure --compressed --head --user-agent '$AGENT' --write-out '%{http_code}\n' $URL
elif [ "$OPT" == "header" ]; then
   curl --silent --insecure --compressed --head --user-agent '$AGENT' $URL
elif [ "$OPT" == "redirect" ]; then
   curl -o /dev/null --silent --insecure --compressed --head --user-agent '$AGENT' --max-time 10 --write-out '%{redirect_url}\n' $URL
elif [ "$OPT" == "archive" ]; then
   curl --silent --max-time 10 "http://archive.org/wayback/available?url=$URL&statuscodes=200&statuscodes=203&statuscodes=206"
   echo
elif [ "$OPT" == "source" ]; then
   curl --silent --insecure --user-agent '$AGENT' $URL
else
   echo "Invalid mode argument '$OPT'. Aborting."
fi