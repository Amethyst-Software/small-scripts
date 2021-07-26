#!/bin/bash

# Back Up Unix Settings
# Saves the contents of your shell settings files into a single handy text file.
# The first parameter should be "bash" or "zsh" to tell the script which shell's
# settings files to save.
# The second parameter is the path and file name for the text file to be created.

WROTE_FIRST_FILE=0
WHICH_SHELL="$1"
BACKUP_DEST="$2"
WRITE_SEP1="echo \"----\" >> \"$BACKUP_DEST\""
WRITE_SEP2="echo -e \"\n----\n----\" >> \"$BACKUP_DEST\""

function backupSettingsFile()
{
   if [ $WROTE_FIRST_FILE -eq 0 ]; then
      echo "$1:" > "$BACKUP_DEST"
      WROTE_FIRST_FILE=1
   else
      echo "$1:" >> "$BACKUP_DEST"
   fi

   # Append settings file's contents to destination file without reporting an
   # error for non-existent settings files
   eval $WRITE_SEP1
   cat "$1" >> "$BACKUP_DEST" 2> /dev/null
   eval $WRITE_SEP2
}

if [ -z "$BACKUP_DEST" ]; then
   echo "You need to supply the path for the output file as the second parameter!"
   exit
fi

if [ "$WHICH_SHELL" == "bash" ]; then
   backupSettingsFile "/etc/profile"
   backupSettingsFile "$HOME/.profile"
   backupSettingsFile "/etc/bashrc"
   backupSettingsFile "$HOME/.bashrc"
   backupSettingsFile "$HOME/.inputrc"
   backupSettingsFile "$HOME/.bash_profile"
   backupSettingsFile "$HOME/.bash_login"
   backupSettingsFile "$HOME/.bash_logout"
elif [ "$WHICH_SHELL" == "zsh" ]; then
   backupSettingsFile "/etc/zshrc"
   backupSettingsFile "$HOME/.zshrc"
   backupSettingsFile "/etc/zshenv"
   backupSettingsFile "$HOME/.zshenv"
   backupSettingsFile "/etc/zprofile"
   backupSettingsFile "$HOME/.zprofile"
   backupSettingsFile "/etc/zlogin"
   backupSettingsFile "$HOME/.zlogin"
   backupSettingsFile "/etc/zlogout"
   backupSettingsFile "$HOME/.zlogout"
else
   echo "'$WHICH_SHELL' is not a supported shell! Please supply 'bash' or 'zsh'."
fi