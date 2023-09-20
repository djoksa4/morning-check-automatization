#!/bin/bash

# Specify the directory you want to count files in
directory="/home/adminuser/morning-check-automatization"

# List files in the directory and then count them
file_count=$(find "$directory" -maxdepth 1 -type f | wc -l)

# Output number of files
echo "Number of files in $directory: $file_count"