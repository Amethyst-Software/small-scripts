# Small Scripts/Bash
Miscellaneous scripts that I've written for my own convenience. Hopefully you find them useful too. Comments in each script provide documentation. Intended to run in the latest version of the Bash shell that is provided in macOS.

Feel free to file an issue if a script is not working for you. Although I originally wrote these for myself, I would like them to be robust and reliable for other users too.

## Contents
[Unix/System](#unixsystem-management)

[General Files A-D](#general-file-management-a-d)

[General Files E-Z](#general-file-management-e-z)

[Development](#development)

[Web](#web)

---

## Unix/System Management
### [Back Up Unix Settings](back_up_unix_settings.sh)
<!--Destination path and name of backup file.-->
Backs up your shell settings in a single text file. [(sample result)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/back_up_unix_settings.png)

### [History Check](history_check.sh)
<!--Name of shell ("bash" or "zsh").-->
Helps you to avoid exceeding your shell's command history limit and losing old history. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/history_check.png)

### [Last Boot Times](last_boot_times.sh)
<!--(none)-->
Lists when each mounted volume was last booted from (whether macOS or Windows). [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/last_boot_times.png)

### [List Startup Items](list_startup_items.sh)
<!--(none)-->
Lists all the files registered on a macOS system as launch daemons, launch agents, and general startup items. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/list_startup_items.png)

### [Man Dump](man_dump.sh)
<!--Name of the Unix command.-->
Saves a readable plain-text copy of the man page for a given command.

### [Update MacPorts](update_macports.sh)
<!--(none)-->
A convenient interactive assistant for updating MacPorts and all installed ports. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/update_macports.png)

---

## General File Management A-D
### [Change File Suffixes](change_file_suffixes.sh)
<!--The directory to search.
The file suffix or suffix regex pattern to look for.
The new suffix to replace it with.-->
Changes all files of suffix X to suffix Y. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/change_file_suffixes.png)

### [Collect Email Addresses](collect_email_addresses.sh)
<!--The directory containing the text files to search.
The directory in which to save the text file full of addresses.
(optional) The argument 'email-from' triggers an alternate mode that searches .emlx files instead of .txt files and only saves the sender address from each email.-->
Saves all email addresses found in a folder's text files or Apple Mail emails (.emlx).

### [Collect File Suffixes](collect_file_suffixes.sh)
<!--The directory to recursively collect suffixes from.-->
Prints out a list of all suffixes used by the files in a directory. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/collect_file_suffixes.png)

### [Compare Directory to List](compare_directory_to_list.sh)
<!--The directory in which to search for files.
The text file with file names to search for.-->
Compares the names of the items in a directory to the file names listed in a text file, and outputs which names are unique to each side. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/compare_directory_to_list.png)

### [Compare File Dates](compare_file_dates.sh)
<!--'--dirpath1' and '--dirpath2' are used for directory comparison.
'--listpath1' and '--listpath2' are used for file comparison.
'--dirfilter' can be used to only look at files in the directories which match a naming pattern.
The directories and/or files you pass in can be named using '--dirname1', '--dirname2', '--listname1' and '--listname2'.-->
Compares two sets of files to make sure that all files in set 1 exist in set 2 and that no files differ in modification date. The compared sets can be either two directories or two plain-text files which list individual files. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/compare_file_dates.png)

### [Compare File Names](compare_file_names.sh)
<!--The first directory to look at.
The second directory to look at.
(optional) The argument "--no-suffix" to ignore file name suffixes during comparison. Can come before or after the directory arguments.-->
Compares the names of the files in two directories and outputs which names are unique to each side. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/compare_file_names.png)

### [Convert with FFmpeg](convert_with_ffmpeg.sh)
<!--The directory to look in.
The suffix of the files to convert.
The suffix to which they should be converted.-->
Searches a directory for a given file suffix and tells ffmpeg to convert all the results to the type indicated by a second given suffix.

### [Count Files by Name](count_files_by_name.sh)
<!--The directory in which to recursively search.
The suffixes to search for.-->
Recursively searches for and counts the specified files in the given directory. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/count_files_by_name.png)

### [Count Lines by Name](count_lines_by_name.sh)
<!--The directory in which to recursively search.
The suffixes to search for.-->
Recursively searches for specified files in the given directory and totals their line counts. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/count_lines_by_name.png)

### [Create Files from List](create_files_from_list.sh)
<!--The path to the file to copy 'n' times.
The text file with the list of names to use for the copies.
The directory in which to make these copies.-->
Given base file X and text file Y, makes one copy of X named for each line in Y in a given directory.

### [Delete Empty Folders](delete_empty_folders.sh)
<!--The directory in which to delete subfolders.-->
Deletes subfolders that do not contain any items.

### [Delete Files in List](delete_files_in_list.sh)
<!--The directory in which to recursively search files.
The regex pattern of file names to search.
The text file with the terms to search for in these files.-->
Searches a directory for files containing any of the terms in a given text file, and moves matching files to the Trash. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/delete_files_in_list.png)

### [Duplicate File and Copy Names](duplicate_file_and_copy_names.sh)
<!--'--copy-file': The path to the file to copy.
'--copy-names': The directory of files with the names to use for the copies, OR the text file with one line for each copy's name.
'--dest': The directory in which to make these copies.
(optional) '--new-suffix': Use this suffix in place of the source file's suffix (no period).-->
Given file X and set of files Y in a given directory, makes one copy of X named for each file in Y.

---

## General File Management E-Z

### [Find and Replace](find_and_replace.sh)
<!--The file in which to search for terms.
The first "in" term to search for.
The term to replace it with.
(optional) The second "in" term to search for.
(optional) The term to replace it with.-->
Replaces the specified terms in a file with new terms, saving the result in a new file.

### [Find Case Conflicts](find_case_conflicts.sh)
<!--(none)-->
Prints out directory items which would have a name conflict in a case-insensitive file system.

### [Find Line Matches](find_line_matches.sh)
<!--The text file with a set of search terms.
The text file to search.-->
Prints out matching lines between file A and file B. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/find_line_matches.png)

### [Find List in Files](find_list_in_files.sh)
<!--The directory in which to recursively search files.
The regex pattern of file names to search.
The text file with the terms to search for in these files.-->
Searches a directory for files containing any of the terms in a given text file.

### [Find Zero-Byte Files](find_zero_byte_files.sh)
<!--(none)-->
Lists all files in the current directory that are zero bytes in size. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/find_zero_byte_files.png)

### [Get Data Totals](get_data_totals.sh)
<!--'--file' followed by the path to the input file that the script should operate upon, OR
'--dir' followed by the directory to get the size of.-->
Takes an input file of a specified format (see script's comments) containing a list of directories to get the sizes of, grouped by category and volume, and displays the results. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/get_data_totals.png)

### [Get Finder Sizes](get_finder_sizes.sh)
<!--The directory to get the size of.-->
An 'osascript' wrapper that allows you to ask Finder from the command line what is the size of a folder. Both logical and physical sizes will be printed. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/get_finder_sizes.png)

### [Get Fork Sizes](get_fork_sizes.sh)
<!--Path to directory to get the fork sizes for.
(optional) '--list-files' will cause each file's fork sizes to be printed to screen.-->
Searching recursively in the supplied directory, checks each file for a resource fork, and totals the sizes of the data and resource forks separately. After printing the fork sizes to screen, the script also predicts what Finder will claim is the size of the folder, accounting for a bug as of macOS 10.14 pertaining to multi-fork files under APFS. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/get_fork_sizes.png)

### [Get Hardlink Sizes](get_hardlink_sizes.sh)
<!--(After '--vol' or '--dir') The directory or volume to recursively search for multi-linked files.
(optional) '--list-files' will list all found files instead of just giving the totals.
(optional) '--bigger-than nUNITS' will only show files larger than 'n' 'UNITS' of size.-->
Finds all hardlinked (multi-linked) files on a volume or in a specified directory and prints out how much space the files take up and how much space is saved through the use of hardlinks. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/get_hardlink_sizes.png)

### [Get Info](get_info.sh)
<!--The directory to get info on.-->
Simulates the Get Info window on the command line by listing the size and item count of a directory. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/get_info.png)

### [Name After Parent](name_after_parent.sh)
<!--The directory with the files to rename.
The suffix of the files to rename.
(optional) 'seq' to change the body of the file name to a number.
(optional) 'dry' to perform a dry run.-->
Given a folder "X", renames each file inside "X-current name". If the argument "seq" is supplied, files will be renamed "X-#", where '#' is the alphabetical ordinal position of the file. [(sample result)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/name_after_parent.png)

### [Rename Emails with Dates](rename_emails_with_dates.sh)
<!--The directory of emails.
The directory to which to copy the emails.
(optional) '--dry-run' will tell you what will be copied without actually copying anything.
(optional) '--stop-on-fail' will stop the script if an email's date cannot be read.-->
Given a folder of .emlx files, assigns each one a name based on the date and time it was sent/received. [(sample result)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/rename_emails_with_dates.png)

### [Rename Files from List](rename_files_from_list.sh)
<!--'--dir': the directory with the contents to be renamed.
'--names-from': the file with the items to search for and rename.
'--names-to': the file with the new names for each item.-->
Given a folder, a list of existing item names, and a list of new names, renames each item from the existing name to the new name.

### [Run Script on Files by Size](run_script_on_files_by_size.sh)
<!--The script that will be run.
The directory of files to appraise.
The minimum size in bytes of files to pass to the script.
The maximum size in bytes of files to pass to the script.-->
Looking at the files in a given directory, pass each one to the specified script if the file is within a certain size range. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/run_script_on_files_by_size.png)

### [Run Script with Args from File](run_script_with_args_from_file.sh)
<!--'--script' followed by the path to the script to run.
'--arglist' followed by the path to the list of arguments to pass to the script.
(optional) '--echo' will print the assembled command before running it.-->
Run a script with the arguments listed in a text file. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/run_script_with_args_from_file.png)

### [Total Sound Times](total_sound_times.sh)
<!--The directory of sound files to examine.
The suffix of the files which should be totalled.-->
Gives the cumulative total time of all AIFFs in a folder. Requires 'ffmpeg' to be installed. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/total_sound_times.png)

### [ZipSafe](zip_safe.sh)
<!--The directory to compress (ZIP is placed next to directory).-->
Creates Windows-friendly ZIPs that lack the Mac's invisible .DS_Store files, also omitting invisible Subversion and Git development directories. Automator workflow version of this script found [here](../Automator).

---

## Development
### [Check for Git Updates](check_for_git_updates.sh)
<!--Path to working copy.-->
Looks for new commits on the remote server which can be pulled into a working copy. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/check_for_git_updates.png)

### [Cloak Dev Paths](cloak_dev_paths.sh)
<!--(none)-->
Prevents your local disk's paths from showing up in an Xcode-built binary. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/cloak_dev_paths.png)

### [Print Certificate Info](print_cert_info.sh)
<!--The directory in which to recursively search for applications.-->
Tells you the developer certificate signing authority for each app in a folder. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/print_cert_info.png)

### [Print Header Comments](print_header_comments.sh)
<!--The directory in which to recursively search source files.-->
Isolates and prints the comment block from the top of each source file in a project. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/print_header_comments.png)

---

## Web
### [Create HTML Gallery](create_html_gallery.sh)
<!--'--dir' followed by the directory containing the folders full of images.
(optional) '--cols' followed by the number of images to place on each row of the gallery table. '0' will create a table-less gallery where the images simply wrap to the width of your browser window.
(optional) '--suff' followed by the suffix of the images to place in the gallery ('jpg' by default).
(optional) '--style' followed by the word 'light', 'dark', or a path to a text file containing the contents you want the gallery's <style> tag to have.
(add'l options; read top of script for details) '--name', '--width'.-->
Creates an HTML listing of a directory's subfolders, and HTML galleries of the images in each subfolder. Requires ImageMagick when using the '--width' argument. [(sample result)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/create_html_gallery.png)

### [Download URLs in List](download_urls_in_list.sh)
<!--The path to the file with the list of URLs.
The folder into which to download the files.-->
Given a text file that has a list of URLs pointing to files, newline-separated, download the linked files into a given directory. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/download_urls_in_list.png)

### [HTTP Tests](http_tests.sh)
<!--The type of response to obtain (run without parameters to see arguments).
The URL to test.-->
Prints the desired type of response (status code, HTTP header, redirect URL, or Internet Archive status code) received upon querying a given URL. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/http_tests.png)

### [Print Chromium History](print_chromium_history.sh)
<!--The name of the browser or the path to the browser's history file.
The date of the desired history in the format 'yyyy-m-d'.
(optional) The time zone offset.-->
Tells you all the sites you visited in a Chromium-based browser on a given day. [(sample usage)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/samples/print_chromium_history.png)

### [Scrape Smugmug Gallery](scrape_smugmug_gallery.sh)
<!--The URL of a Smugmug gallery.
The directory in which to save the media.-->
Saves all images and movies from a Smugmug album.
