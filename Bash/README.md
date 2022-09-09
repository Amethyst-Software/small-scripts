# Small Scripts/Bash
Miscellaneous scripts that I've written for my own convenience. Hopefully you find them useful too. Comments in each script provide documentation. Intended to run in the latest version of the Bash shell that is provided in macOS.

Feel free to file an issue if a script is not working for you. Although I originally wrote these for myself, I would like them to be robust and reliable for other users too.

## Contents
[Unix/System](#unixsystem-management)

[General Files](#general-file-management)

[Image Files](#image-file-management)

[Audio Files](#audio-file-management)

[Development](#development)

[Web](#web)

---

## Unix/System Management
### [Back Up Unix Settings](back_up_unix_settings.sh)
<!--Destination path and name of backup file.-->
Backs up your shell settings in a single text file. [(sample output)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/back_up_unix_settings.jpg)

### [History Check](history_check.sh)
<!--Name of shell ("bash" or "zsh").-->
Helps you to avoid exceeding your shell's command history limit and losing old history. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/history_check.jpg)

### [Last Boot Times](last_boot_times.sh)
<!--(none)-->
Lists when each mounted volume was last booted from (whether macOS or Windows). [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/last_boot_times.jpg)

### [List Startup Items](list_startup_items.sh)
<!--(none)-->
Lists all the files registered on a macOS system as launch daemons, launch agents, and general startup items. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/list_startup_items.jpg)

### [Man Dump](man_dump.sh)
<!--Name of the Unix command.-->
Saves a readable plain-text copy of the man page for a given command.

### [Update MacPorts](update_macports.sh)
<!--(none)-->
A convenient interactive assistant for updating MacPorts and all installed ports. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/update_macports.jpg)

---

## General File Management
### [Change File Suffixes](change_file_suffixes.sh)
<!--The directory to search.
The file suffix or suffix regex pattern to look for.
The new suffix to replace it with.-->
Changes all files of suffix X to suffix Y.

### [Collect Email Addresses](collect_email_addresses.sh)
<!--The directory containing the text files to search.
The directory in which to save the text file full of addresses.
(optional) The argument 'email-from' triggers an alternate mode that searches .emlx files instead of .txt files and only saves the sender address from each email.-->
Saves all email addresses found in a folder's text files or Apple Mail emails (.emlx).

### [Collect File Suffixes](collect_file_suffixes.sh)
<!--The directory to recursively collect suffixes from.-->
Prints out a list of all suffixes used by the files in a directory. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/collect_file_suffixes.jpg)

### [Compare File Names in Directories](compare_file_names_in_directories.sh)
<!--The first directory to look at.
The second directory to look at.
(optional) The argument "--no-suffix" to ignore file name suffixes during comparison.-->
Compares the names of the files in two directories and outputs which names are unique to each side.

### [Compare Directory to List](compare_directory_to_list.sh)
<!--The directory in which to search for files.
The text file with file names to search for.-->
Compares the names of the items in a directory to the file names listed in a text file, and outputs which names are unique to each side.

### [Count Files by Name](count_files_by_name.sh)
<!--The directory in which to recursively search.
The suffixes to search for.-->
Recursively searches for and counts the specified files in the given directory.

### [Count Lines by Name](count_lines_by_name.sh)
<!--The directory in which to recursively search.
The suffixes to search for.-->
Recursively searches for specified files in the given directory and totals their line counts.

### [Create Files from List](create_files_from_list.sh)
<!--The path to the file to copy 'n' times.
The text file with the list of names to use for the copies.
The directory in which to make these copies.-->
Given base file X and text file Y, makes one copy of X named for each line in Y in a given directory.

### [Delete Files in List](delete_files_in_list.sh)
<!--The directory in which to recursively search files.
The regex pattern of file names to search.
The text file with the terms to search for in these files.-->
Searches a directory for files containing any of the terms in a given text file, and moves matching files to the Trash.

### [Duplicate File and Copy Names](duplicate_file_and_copy_names.sh)
<!--The path to the file to copy 'n' times.
The directory of files with the names to use for the copies.
The directory in which to make these copies.-->
Given file X and set of files Y in a given directory, makes one copy of X named for each file in Y.

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
Prints out matching lines between file A and file B.

### [Find List in Files](find_list_in_files.sh)
<!--The directory in which to recursively search files.
The regex pattern of file names to search.
The text file with the terms to search for in these files.-->
Searches a directory for files containing any of the terms in a given text file.

### [Find Zero-Byte Files](find_zero_byte_files.sh)
<!--(none)-->
Lists all files in the current directory that are zero bytes in size.

### [Get Data Totals](get_data_totals.sh)
<!--'--file' followed by the path to the input file that the script should operate upon, OR
'--dir' followed by the directory to get the size of.-->
Takes an input file of a specified format (see script's comments) containing a list of directories to get the sizes of, grouped by category and volume, and displays the results. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/get_data_totals.png)

### [Get Finder Sizes](get_finder_sizes.sh)
<!--The directory to get the size of.-->
An 'osascript' wrapper that allows you to ask Finder from the command line what is the size of a folder. Both logical and physical sizes will be printed. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/get_finder_sizes.png)

### [Get Fork Sizes](get_fork_sizes.sh)
<!--Path to directory to get the fork sizes for.
(optional) '--list-files' will cause each file's fork sizes to be printed to screen.-->
Searching recursively in the supplied directory, checks each file for a resource fork, and totals the sizes of the data and resource forks separately. After printing the fork sizes to screen, the script also predicts what Finder will claim is the size of the folder, accounting for a bug as of macOS 10.14 pertaining to multi-fork files under APFS. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/get_fork_sizes.png)

### [Get Hardlink Sizes](get_hardlink_sizes.sh)
<!--(After "--vol" or "--dir") The directory or volume to recursively search for multi-linked files.
(optional) "--list-files" will list all found files instead of just giving the totals.
(optional) "--bigger-than nUNITS" will only show files larger than 'n' "UNITS" of size.-->
Finds all hardlinked (multi-linked) files on a volume or in a specified directory and prints out how much space the files take up and how much space is saved through the use of hardlinks. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/get_hardlink_sizes.jpg)

### [Get Info](get_info.sh)
<!--The directory to get info on.-->
Simulates the Get Info window on the command line by listing the size and item count of a directory. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/get_info.png)

### [Rename Emails with Dates](rename_emails_with_dates.sh)
<!--The directory of emails.
The directory to which to copy the emails.
(optional) '--dry-run' will tell you what will be copied without actually copying anything.
(optional) '--stop-on-fail' will stop the script if an email's date cannot be read.-->
Given a folder of .emlx files, assigns each one a name based on the date and time it was sent/received.

### [Rename Sequentially](rename_sequentially.sh)
<!--The directory with the files to rename.
The suffix of the files to rename.-->
Given a parent folder X, renames each file of a given suffix in X to be "X-#", where '#' is the alphabetical ordinal position of the file.

### [Run Script on Files by Size](run_script_on_files_by_size.sh)
<!--The script that will be run.
The directory of files to appraise.
The minimum size in bytes of files to pass to the script.
The maximum size in bytes of files to pass to the script.-->
Looking at the files in a given directory, pass each one to the specified script if the file is within a certain size range.

### [Run Script with Args from File](run_script_with_args_from_file.sh)
<!--'--script' followed by the path to the script to run.
'--arglist' followed by the path to the list of arguments to pass to the script.
(optional) '--echo' will print the assembled command before running it.-->
Run a script with the arguments listed in a text file.

### [ZipSafe](zip_safe.sh)
<!--The directory to compress (ZIP is placed next to directory).-->
Creates Windows-friendly ZIPs that lack the Mac's invisible .DS_Store files, also omitting invisible Subversion and Git development directories.  Automator workflow version of this script found [here](../Automator).

---

## Image File Management
### [Convert Images](convert_images.sh)
<!--(none)-->
Converts all images of a given suffix to another format. Requires ImageMagick.

### [Create HTML Gallery](create_html_gallery.sh)
<!--The top directory of the folders full of images.-->
Creates an HTML directory listing of all subfolders, and an HTML gallery of all images in each subfolder. Requires ImageMagick.

### [Crop Images](crop_images.sh)
<!--The directory of images to create cropped copies of.
The width to crop them to.
The height to crop them to.
The left inset.
The top inset.-->
Crops a folder of images using a certain offset and size. Requires ImageMagick.

### [Find Images by Size](find_images_by_size.sh)
<!--The directory to search recursively for images.
The minimum desired width of results.
The word 'and' or 'or' (whether only the min. width or min. height needs to be met, or both).
The minimum desired height of results.
(optional) The word 'port' or 'land' for only portrait or only landscape results.-->
Prints out names of files that meet a minimum specified width/height and optional portrait/landscape orientation. Requires ImageMagick.

### [Resize Images](resize_images.sh)
<!--'--source' followed by the directory with the images to be resized.
(choose one) '--overwrite', '--beside', or '--dest PATH': Whether to overwrite the original images, place the resized copies beside them, or place the resized copies in PATH.
'--new-percent:NUM', or '--new-width:NUM' and/or '--new-height:NUM': The new size for the images.
'--old-[width|height]-[eq|lt|le|gt|ge]:NUM': Only resize images matching this criterion. An example would be '--old-width-gt:10000', which would resize images above 10K pixels in width. You can only use one '--old-width-*' argument at a time, but you can use one '--old-width-*" argument and one '--old-height-*' argument together.-->
Resizes all images, or only the images of a certain size, if desired. Requires ImageMagick.

---

## Audio File Management
### [Total Sound Times](total_sound_times.sh)
<!--The directory of sound files to examine.
The suffix of the files which should be totalled.-->
Gives the cumulative total time of all AIFFs in a folder. Requires 'ffmpeg' to be installed. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/total_sound_times.jpg)

---

## Development
### [Check for Git Updates](check_for_git_updates.sh)
<!--Path to working copy.-->
Looks for new commits on the remote server which can be pulled into a working copy.

### [Check for Script Updates](check_for_script_updates.sh)
<!--(none)-->
Looks for working copies of scripts that are newer than the copies under version control. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/check_for_script_updates.jpg)

### [Cloak Dev Paths](cloak_dev_paths.sh)
<!--(none)-->
Prevents your local disk's paths from showing up in an Xcode-built binary.

### [Print Certificate Info](print_cert_info.sh)
<!--The directory in which to recursively search for applications.-->
Tells you the developer certificate signing authority for each app in a folder. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/print_cert_info.jpg)

### [Print Header Comments](print_header_comments.sh)
<!--The directory in which to recursively search source files.-->
Isolates and prints the comment block from the top of each source file in a project. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/print_header_comments.png)

---

## Web
### [Download URLs in List](download_urls_in_list.sh)
<!--The path to the file with the list of URLs.
The folder into which to download the files.-->
Given a text file that has a list of URLs pointing to files, newline-separated, download the linked files into a given directory.

### [HTTP Tests](http_tests.sh)
<!--The type of response to obtain (run without parameters to see arguments).
The URL to test.-->
Prints the desired type of response (status code, HTTP header, redirect URL, or Internet Archive status code) received upon querying a given URL. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/http_tests.jpg)

### [Print Chromium History](print_chromium_history.sh)
<!--The name of the browser or the path to the browser's history file.
The date of the desired history in the format 'yyyy-m-d'.
(optional) The time zone offset.-->
Tells you all the sites you visited in a Chromium-based browser on a given day. [(preview image)](https://github.com/Amethyst-Software/small-scripts/blob/main/Bash/previews/print_chromium_history.jpg)

### [Scrape Smugmug Gallery](scrape_smugmug_gallery.sh)
<!--The URL of a Smugmug gallery.
The directory in which to save the media.-->
Saves all images and movies from a Smugmug album.
