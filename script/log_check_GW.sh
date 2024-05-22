#!/bin/bash

# Define the log file path
log_file="/home/wl12/morning-check-automatization/deletion-logs/deletion_log.log"

# Define the directory paths
GW_logs_dir="/spimi/logs/weblogic/fcbi0gw/Gateway/"
archive_dir="/spimi/logs/weblogic/fcbi0gw/Gateway/archive/"

# Get the current date and time
current_datetime=$(date "+%Y-%m-%d %H:%M:%S")


# Log the execution of the script
echo "$current_datetime - Script executing..." >> "$log_file"
echo "--------------------------------------------------------------------" >> "$log_file"


dir_array=(GWWS GWEJB)

for dir in "${dir_array[@]}"; do

  # Move all the app log files older than 1 day to archive
  gw_logs_file_count=$(find "$GW_logs_dir$dir/" -maxdepth 1 -type f | wc -l)
  echo "$current_datetime - $gw_logs_file_count files found in the $dir logs directory. Moving $dir log files older than 1 day to archive..." >> "$log_file"  

  temp_file="$(mktemp)"
  find "$GW_logs_dir$dir/" -type f ! -newermt $(date +%Y-%m-%d) \( -name '*.gz' -o -name '*.log' \) -exec mv {} "$archive_dir$dir/" \; -print >> "$temp_file"
  moved_files_count=$(wc -l < "$temp_file")
  rm -f "$temp_file"

  new_gw_logs_file_count=$(find "$GW_logs_dir$dir/" -maxdepth 1 -type f | wc -l)
  echo "$current_datetime - Found and moved $moved_files_count $dir log files to archive. $new_gw_logs_file_count files remain in the $dir logs directory." >> "$log_file"
  echo "----------------------------------" >> "$log_file"

  # Check the number of files in the archive AFTER the move from logs dir
  archive_file_count=$(find "$archive_dir$dir/" -maxdepth 1 -type f | wc -l)

  # If there are more than 2000 files in the archive_directory after the move, log an error and exit
  if [ "$archive_file_count" -gt 2000 ]; then
    echo "$current_datetime - Error: Unexpectedly large amount of files present in the $dir archive ($archive_file_count files). Aborting archive deletion." >> "$log_file"
    echo "--------------------------------------------------------------------" >> "$log_file"
  else
    # Print the number of files present in the archive_directory
    echo "$current_datetime - Total of $archive_file_count log files found in the $dir archive directory. Deleting files older than 7 days..." >> "$log_file"

    # Delete files with timestamps older than 7 days in the archive_directory
    find "$archive_dir$dir/" -type f -mtime +7 -exec rm {} \;

    # Print the new number of files after deletion
    new_archive_file_count=$(find "$archive_dir$dir/" -maxdepth 1 -type f | wc -l)

    echo "$current_datetime - Total of $new_archive_file_count log files left in the $dir archive directory after deletion." >> "$log_file"
    echo "--------------------------------------------------------------------" >> "$log_file"
  fi

done

echo "====================================================================" >> "$log_file"