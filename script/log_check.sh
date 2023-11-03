#!/bin/bash

# Define the log file path
log_file="/home/wl12/morning-check-automatization/deletion-logs/deletion_log.log"

# Define the directory paths
app_logs_directory="/home/wl12/morning-check-automatization/files/spimi/logs/weblogic/fcbi0/fcubs123/"
front_sys_directory="/home/wl12/morning-check-automatization/files/spimi/beaConfigManaged/wls12.2.1.4/userApps/fcbi0/config/JS_UIXML/Script/JS/SYS/"
archive_directory="/home/wl12/morning-check-automatization/files/archive/"

# Get the current date and time
current_datetime=$(date "+%Y-%m-%d %H:%M:%S")




# Log the execution of the script
echo "$current_datetime - Script executing..." >> "$log_file"

# Count the number of SYS files, delete them and log the deletion
front_sys_file_count=$(find "$front_sys_directory" -maxdepth 1 -type f | wc -l)
rm -v "$front_sys_directory"*js
echo "$current_datetime - $front_sys_file_count Frontend SYS files found and deleted." >> "$log_file" 




# Move all the app log files older than 1 day to archive
echo "$current_datetime - Moving app log files older than 1 day to archive..." >> "$log_file"
moved_files_count=0
find "$app_logs_directory" -type f ! -newermt $(date +%Y-%m-%d) \( -name 'EMS*' -o -name 'NOTIF*' -o -name 'Scheduler*' -o -name '*.gz' \) -exec mv {} "$archive_directory" \; -exec sh -c 'moved_files_count=$((moved_files_count + 1))' \;
echo "$current_datetime - Found and moved $moved_files_count app log files to archive." >> "$log_file"





# Check the number of files in the archive AFTER the move from app_logs_dir
archive_file_count=$(find "$archive_directory" -maxdepth 1 -type f | wc -l)

# If there are more than 10,000 files in the archive_directory after the move, log an error and exit
if [ "$archive_file_count" -gt 10000 ]; then
    echo "$current_datetime - Error: Unexpectedly large amount of files present in the archive ($archive_file_count files). Aborting." >> "$log_file"
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