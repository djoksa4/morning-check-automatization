#!/bin/bash

# Specify the directory you want to count files in
directory="/home/adminuser/morning-check-automatization"

# List files in the directory and then count them
file_count=$(find "$directory" -maxdepth 1 -type f | wc -l)

# Output number of files
echo "Number of files in $directory: $file_count"


# Check if the file count is greater than 1000
if [ "$file_count" -gt 20 ]; then
    # Notify that file deletion is starting
    echo "Starting deletion of $file_count files in $directory..."
    
    # Delete all files in the directory
    find "$directory" -type f -exec rm -f {} \;
    
    # Use 'find' again to count the remaining files after deletion
    new_file_count=$(find "$directory" -type f | wc -l)
    
    # Output the information about file deletion and the new file count
    echo "Deleted $file_count files in $directory."
    echo "New number of files in $directory: $new_file_count"
else
    # Output message when file deletion is not needed
    echo "File deletion not needed."
fi