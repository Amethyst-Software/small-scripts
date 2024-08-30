#!/bin/bash

# Print Chromium History
# Prints out the URLs visited and the files downloaded on a given day by reading the history database of a
# Chromium-based browser using 'sqlite3'.
# Parameters:
# 1. The name of the browser or the path to the browser's history file.
# 2. The date for the history lookup.
# 3. (optional) The time zone offset.
# Known bugs: Sometimes a time offset is necessary to get the correct 24-hour period, and sometimes it isn't.
# Recommended rule:
# |---------------------------------------------------------------------------------------------------------|

# Parse date parameter and then set IFS to newline avoid breaking file paths
IFS="-"
declare -a DATE_PARTS=($2)
IFS="
"

# Known paths of browser history files
declare -a BROWSER_NAMES=(Opera Brave Chrome SampleBrowser)
declare -a BROWSER_HIST_PATHS=("$HOME/Library/Application Support/com.operasoftware.Opera/Default/History" "$HOME/Library/Application Support/BraveSoftware/Brave-Browser/Default/History" "$HOME/Library/Application Support/Google/Chrome/Default/History" "/path/to/history file")

HIST_PATH="$1"
HUMAN_YEAR=$(echo ${DATE_PARTS[0]} | sed 's/^0*//')
HUMAN_MONTH=$(echo ${DATE_PARTS[1]} | sed 's/^0*//')
HUMAN_DAY=$(echo ${DATE_PARTS[2]} | sed 's/^0*//')
TZ_OFFSET="$3"

##ARGUMENT PROCESSING##
if [ $# -ne 2 ] && [ $# -ne 3 ]; then
   echo "You need to supply the following arguments:"
   echo "1. 'Opera'/'Brave'/'Chrome', which will automatically look up that browser's history file, OR"
   echo "   'PATH', the path to a history file for such a browser."
   echo "2. A date in the format 'yyyy-m-d'."
   echo "3. (optional) An offset adjustment in hours for your time zone. Chromium's timestamps are in UTC, so to get the actual history for your chosen day's 24-hour period, you may need to plug in the reverse of your TZ offset. For example, if you are in the ET time zone (UTC-05:00), supply "5" as the offset." | fmt -w 80
fi

# Check arg 1 against known browsers
a=0
while [ "x${BROWSER_NAMES[$a]}" != "x" ]; do
   if [ "${BROWSER_NAMES[$a]}" == "$1" ]; then
      HIST_PATH=${BROWSER_HIST_PATHS[$a]}
   fi
   let a+=1
done

if [ ! -f "$HIST_PATH" ]; then
   echo "History file not found at path $HIST_PATH. Exiting."
   exit
fi

if [ -z $HUMAN_YEAR ] || [ $HUMAN_YEAR -lt 1 ] || [ $HUMAN_YEAR -gt 9999 ]; then
   echo "Year out of expected range of 1 AD-9,999 AD! Exiting."
   exit
fi

if [ -z $HUMAN_MONTH ] || [ $HUMAN_MONTH -lt 1 ] || [ $HUMAN_MONTH -gt 12 ]; then
   echo "Month out of expected range of 1-12! Exiting."
   exit
fi

if [ -z $HUMAN_DAY ] || [ $HUMAN_DAY -lt 1 ] || [ $HUMAN_DAY -gt 31 ]; then
   echo "Day out of expected range of 1-31! Exiting."
   exit
fi

if [ -z $TZ_OFFSET ]; then
   TZ_OFFSET=0
fi

## TIME UTILITIES ##
# Converts a raw date, as stored on disk by Chromium-based browsers, to a human-readable one. The input to
# this function should be a number 17 digits long, and around 13 quadrillion, e.g. 13180923665109490 for
# a time on Sep. 8, 2018 AD
function convertChromiumTimeToHumanTime()
{
   SEARCH_DATE=$1

   # Difference between bases of Unix epoch and Chrome epoch, which is 1601 AD for some reason
   let UNIX_CHROME_YEAR_DIFF=1970-1601

   # Convert to seconds, since Chrome time is in microseconds for some reason
   let UNIX_DATE=$SEARCH_DATE/1000000

   # Get human time
   NICE_DATE=$(date -r $UNIX_DATE -v -${UNIX_CHROME_YEAR_DIFF}y "+%Y-%m-%d %H-%M-%S")

   # Same, but apply a time zone
   #NICE_DATE=$(TZ=":UTC" date -r $UNIX_DATE -v -${UNIX_CHROME_YEAR_DIFF}y "+%Y-%m-%d %H-%M-%S")

   echo $NICE_DATE
}

# It is a leap year if the year is divisible by 4, unless it is also divisible by 100, unless it is ALSO
# divisible by 400
function isLeapYear()
{
   addOne=0
   if [ $(($1 % 4)) -eq 0 ]; then
      addOne=1
      if [ $(($1 % 100)) -eq 0 ]; then
         addOne=0
         if [ $(($1 % 400)) -eq 0 ]; then
            addOne=1 # stop toying with my heart
         fi
      fi
   fi

   echo $addOne
}

# Returns number of days that passed from 1601 AD through the year before the one passed in as the sole
# parameter
function getDaysBeforeYearX()
{
   sumDays=0
   curYear=$1
   while [ $curYear -gt $CHROME_EPOCH_YEAR ]; do
      let sumDays+=365
      let sumDays+=$(isLeapYear $((curYear - 1)))
      let curYear-=1
   done
   echo $sumDays
}

# Returns number of days that passed from Jan. 1 through the end of the month before the one passed in as
# the first parameter. You must pass in the year as the second parameter so we can tell how many days Feb.
# has.
function getDaysBeforeMonthXInYearY()
{
   sumDays=0
   curMonth=$1
   declare -a MONTH_DAYS=(31 28 31 30 31 30 31 31 30 31 30 31)

   # As long as we are looking back no further than Jan., look up the days
   # in the month before this one
   while [ $curMonth -gt 1 ]; do
      let sumDays+=MONTH_DAYS[$((curMonth - 2))]
      # If we are looking back to Feb., adjust for possible leap day
      if [ $curMonth -eq 3 ]; then
         let sumDays+=$(isLeapYear $2)
      fi
      let curMonth-=1
   done
   echo $sumDays
}

# Converts a human-style date, passed as the parameters "year month day", to the format that Chromium-based
# browsers store on disk in their records.
function convertHumanTimeToChromiumTime()
{
   SEARCH_YEAR=$1
   SEARCH_MONTH=$2
   SEARCH_DAY=$3

   CHROME_EPOCH_YEAR=1601
   CHROME_EPOCH_MONTH=1
   CHROME_EPOCH_DAY=1

   # Size of an hour in Chrome time (60m * 60s * 1,000,000µs)
   HOUR_SIZE=3600000000

   # Normalize to Chrome epoch
   let YEAR_DIFF=$SEARCH_YEAR-$CHROME_EPOCH_YEAR
   let MONTH_DIFF+=$SEARCH_MONTH-$CHROME_EPOCH_MONTH
   let DAY_DIFF+=$SEARCH_DAY-$CHROME_EPOCH_DAY

   # Convert it all to days
   YEAR_DIFF_DAYS=$(getDaysBeforeYearX $SEARCH_YEAR)
   MONTH_DIFF_DAYS=$(getDaysBeforeMonthXInYearY $SEARCH_MONTH $SEARCH_YEAR)

   # Convert it all to seconds
   let DAY_DIFF_SEC=$DAY_DIFF*24*60*60
   let MONTH_DIFF_SEC=$MONTH_DIFF_DAYS*24*60*60
   let YEAR_DIFF_SEC=$YEAR_DIFF_DAYS*24*60*60

   # Convert it all to microseconds
   let CHROME_TIME=$DAY_DIFF_SEC+$MONTH_DIFF_SEC+$YEAR_DIFF_SEC
   let CHROME_TIME*=1000000

   # Adjust for time zone and return the Chrome time
   let CHROME_TIME+=$((TZ_OFFSET * HOUR_SIZE))
   echo $CHROME_TIME
}

## MAIN FUNCTION ##
# Copy file at HIST_PATH to a temp dir, because the original db will be locked if the browser is currently
# open
TMP_HIST_DIR="$(dirname $(mktemp -d))"
cp "$HIST_PATH" "$TMP_HIST_DIR"
TRUE_HIST_PATH="$TMP_HIST_DIR/$(basename $HIST_PATH)"

# Size of a day in Chrome time (24h * 60m * 60s * 1,000,000µs)
DAY_SIZE=86400000000

# Get start and end of desired day in Chrome time
CHROME_DAY=$(convertHumanTimeToChromiumTime $HUMAN_YEAR $HUMAN_MONTH $HUMAN_DAY)
let CHROME_DAY_PLUS_ONE=$CHROME_DAY+$DAY_SIZE

# Pull 'url' and 'visit_time' fields from table 'visits' and use 'url' (an internal ID) to get actual URL
# from table 'urls'
NUM_VISITS=0
echo -n "$NUM_VISITS visits found..."
declare -a RESULTS=()
for RECORD in `sqlite3 "$TRUE_HIST_PATH" 'SELECT url,visit_time FROM ( SELECT * FROM visits WHERE visit_time > '$CHROME_DAY' ) WHERE visit_time < '$CHROME_DAY_PLUS_ONE' ORDER BY visit_time ASC;'`; do
   URL_ID=`echo $RECORD | cut -d '|' -f 1`
   CHROME_DATE=`echo $RECORD | cut -d '|' -f 2`
   HUMAN_DATE=$(convertChromiumTimeToHumanTime $CHROME_DATE)
   THE_URL=$(sqlite3 "$TRUE_HIST_PATH" 'SELECT url FROM urls WHERE id = '$URL_ID';')
   RESULTS+=($(echo "$HUMAN_DATE: Visited $THE_URL"))
   let NUM_VISITS+=1
   printf "\e[1A\n" # erase previous "found..." message so new one appears in its place
   echo -n "$NUM_VISITS visits found..."
done
echo

# Pull 'current_path' and 'start_time' fields from table 'downloads'
NUM_DOWNLOADS=0
echo -n "$NUM_DOWNLOADS downloads found..."
for RECORD in `sqlite3 "$TRUE_HIST_PATH" 'SELECT current_path,start_time FROM ( SELECT * FROM downloads WHERE start_time > '$CHROME_DAY' ) WHERE start_time < '$CHROME_DAY_PLUS_ONE' ORDER BY start_time ASC;'`; do
   FILE_PATH=`echo $RECORD | cut -d '|' -f 1`
   FILE_NAME=$(basename "$FILE_PATH")
   CHROME_DATE=`echo $RECORD | cut -d '|' -f 2`
   HUMAN_DATE=$(convertChromiumTimeToHumanTime $CHROME_DATE)
   RESULTS+=($(echo "$HUMAN_DATE: Downloaded $FILE_NAME"))
   let NUM_DOWNLOADS+=1
   printf "\e[1A\n" # erase previous "found..." message so new one appears in its place
   echo -n "$NUM_DOWNLOADS downloads found..."
done
echo

# Output sorted results (timestamp comes first, so downloads and visits will be chronologically interleaved)
declare -a SORTED_RESULTS=($(sort <<< "${RESULTS[*]}"))
for RESULT in "${SORTED_RESULTS[@]}"; do
   echo $RESULT
done

# Clean up temp copy of db
rm "$TRUE_HIST_PATH"