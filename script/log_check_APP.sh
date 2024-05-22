#!/bin/bash

# Define the log file path
log_file="/home/wl12/morning-check-automatization/deletion-logs/deletion_log.log"

# Define the directory paths
app_logs_directory="/spimi/logs/weblogic/fcbi0/fcubs123/"
front_sys_directory="/spimi/beaConfigManaged/wls12.2.1.4/userApps/fcbi0/config/JS_UIXML/Script/JS/SYS/"
archive_directory="/spimi/logs/weblogic/fcbi0/fcubs123/archive/"

# Get the current date and time
current_datetime=$(date "+%Y-%m-%d %H:%M:%S")

# Log the execution of the script
echo "$current_datetime - Script executing..." >> "$log_file"


# Count the number of SYS files, delete them and log the deletion
front_sys_file_count=$(find "$front_sys_directory" -maxdepth 1 -type f | wc -l)

if [ "$front_sys_file_count" -gt 200 ]; then
    echo "$current_datetime - Error: Unexpectedly large amount of files present in the JS SYS folder ($front_sys_directory files)! Aborting SYS deletion." >> "$log_file"
    echo "--------------------------------------------------------------------" >> "$log_file"
else
    rm -v "$front_sys_directory"*js
    echo "$current_datetime - $front_sys_file_count Frontend SYS files found and deleted." >> "$log_file"
    echo "--------------------------------------------------------------------" >> "$log_file"
fi


# Move all the app log files older than 1 day to archive
app_logs_file_count=$(find "$app_logs_directory" -maxdepth 1 -type f | wc -l)
echo "$current_datetime - $app_logs_file_count files found in the app logs directory. Moving app log files older than 1 day to archive..." >> "$log_file"

temp_file="$(mktemp)"
find "$app_logs_directory" -type f ! -newermt $(date +%Y-%m-%d) \( -name 'EMS*' -o -name 'NOTIF*' -o -name 'Scheduler*' -o -name '*.gz' \) -exec mv {} "$archive_directory" \; -print >> "$temp_file"
moved_files_count=$(wc -l < "$temp_file")
rm -f "$temp_file"

new_app_logs_file_count=$(find "$app_logs_directory" -maxdepth 1 -type f | wc -l)
echo "$current_datetime - Found and moved $moved_files_count app log files to archive. $new_app_logs_file_count files remain in the app logs directory." >> "$log_file"
echo "--------------------------------------------------------------------" >> "$log_file"


# Check the number of files in the archive AFTER the move from app_logs_dir
archive_file_count=$(find "$archive_directory" -maxdepth 1 -type f | wc -l)

# If there are more than 2000 files in the archive_directory after the move, log an error and exit
if [ "$archive_file_count" -gt 2000 ]; then
    echo "$current_datetime - Error: Unexpectedly large amount of files present in the archive ($archive_file_count files). Aborting archive deletion." >> "$log_file"
    echo "====================================================================" >> "$log_file"
    exit 1
else
    # Print the number of files present in the archive_directory
    echo "$current_datetime - Total of $archive_file_count app log files found in the archive directory. Deleting files older than 7 days..." >> "$log_file"

    # Delete files with timestamps older than 7 days in the archive_directory
    find "$archive_directory" -type f -mtime +7 -exec rm {} \;

    # Print the new number of files after deletion
    new_archive_file_count=$(find "$archive_directory" -maxdepth 1 -type f | wc -l)

    echo "$current_datetime - Total of $new_archive_file_count app log files left in the archive directory after deletion." >> "$log_file"
    echo "====================================================================" >> "$log_file"
fi
