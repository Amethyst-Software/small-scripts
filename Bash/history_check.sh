#!/bin/bash

# History Check
# Checks the number of commands in your Bash or Zsh shell history file against
# the maximum number of commands that the shell is set to store. Assumes the
# presence of a setting for $HISTFILESIZE in your .bash_profile or for
# $SAVEHIST in your .zshrc, so adjust accordingly for your own config. Pass
# in "bash" to check the Bash settings and "zsh" for Zsh.

IFS=" "

if [ "$1" == "bash" ]; then
   # Get line count of history file by extracting first word of 'wc' output
   HISTORY_WC_OUTPUT=$(wc -l $HOME/.bash_history)
   declare -a HISTORY_WC_OUTPUT_ARRAY=($HISTORY_WC_OUTPUT)
   HISTORY_LINE_COUNT=${HISTORY_WC_OUTPUT_ARRAY[0]}

   # Get setting for maximum history commands on disk
   HISTORY_MAXSIZE=`grep "HISTFILESIZE" $HOME/.bash_profile | cut -f 2 -d ' ' | cut -f 2 -d '='`

   echo "History is up to $HISTORY_LINE_COUNT commands, and the max allowed per .bash_profile is $HISTORY_MAXSIZE."
elif [ "$1" == "zsh" ]; then
   HISTORY_WC_OUTPUT=$(wc -l $HOME/.zsh_history)
   declare -a HISTORY_WC_OUTPUT_ARRAY=($HISTORY_WC_OUTPUT)
   HISTORY_LINE_COUNT=${HISTORY_WC_OUTPUT_ARRAY[0]}

   HISTORY_MAXSIZE=`grep "SAVEHIST" $HOME/.zshrc | cut -f 2 -d ' ' | cut -f 2 -d '='`

   echo "History is up to $HISTORY_LINE_COUNT commands, and the max allowed per .zshrc is $HISTORY_MAXSIZE."
else
   echo "Unrecognized shell name or no shell name passed in!"
fi