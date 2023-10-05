#!/bin/bash

# Define the log file path
log_file="/home/adminuser/morning-check-automatization/logs/deletion_log.log"

# Define the directory to check
directory_to_check="/home/adminuser/morning-check-automatization/files"

# Get the current date and time
current_datetime=$(date "+%Y-%m-%d %H:%M:%S")

# Count the number of files in the directory (only in the top-level directory)
file_count=$(find "$directory_to_check" -maxdepth 1 -type f | wc -l)

# Log the execution of the script
echo "$current_datetime - Script executed!" >> "$log_file"

# Check the file count
if [ "$file_count" -lt 10 ]; then
    # If less than 10 files, log and do not delete
    echo "$current_datetime - $file_count files found. Deletion not necessary!" >> "$log_file"
    echo "====================================================================" >> "$log_file"
else
    # If 10 or more files, delete only files (not directories) and log the deletion
    echo "$current_datetime - $file_count files found. Deleting all files." >> "$log_file"
    find "$directory_to_check" -maxdepth 1 -type f -exec rm -f {} \;
    echo "$current_datetime - Deleted $file_count files." >> "$log_file"
    echo "====================================================================" >> "$log_file"
fi