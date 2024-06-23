#!/usr/bin/env python 

import os
import glob
from datetime import datetime
import shutil

#### Paths #####################################################################################################
# Define the log file path
log_file = "/home/wl12/morning-check-automatization/deletion-logs/APP_deletion_log.log"

# Define the directory paths
app_logs_directory = "/spimi/logs/weblogic/fcbi0/fcubs123/"
front_sys_directory = "/spimi/beaConfigManaged/wls12.2.1.4/userApps/fcbi0/config/JS_UIXML/Script/JS/SYS/"
archive_directory = "/spimi/logs/weblogic/fcbi0/fcubs123/archive/"

#### Get the current date and time #############################################################################
current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

#### Log the execution of the script ###########################################################################
with open(log_file, "a") as log:
    log.write(f"{current_datetime} - Script executing...\n")


#### Count the number of SYS files, delete them, and log the deletion ##########################################
front_sys_files = glob.glob(f"{front_sys_directory}*.js")
front_sys_file_count = len(front_sys_files)

if front_sys_file_count > 200:
    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - Error: Unexpectedly large amount of files present in the JS SYS folder ({front_sys_file_count} files)! Aborting SYS deletion.\n")
        log.write("--------------------------------------------------------------------\n")
else:
    for file_path in front_sys_files:
        try:
            os.remove(file_path)
        except Exception as e:
            with open(log_file, "a") as log:
                log.write(f"{current_datetime} - Error deleting {file_path}: {str(e)}\n")

    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - {front_sys_file_count} Frontend SYS files found and deleted.\n")
        log.write("--------------------------------------------------------------------\n")


#### Move all app log files older than 1 day to archive ########################################################
app_logs_files = glob.glob(f"{app_logs_directory}*.*")
app_logs_file_count = len(app_logs_files)

with open(log_file, "a") as log:
    log.write(f"{current_datetime} - {app_logs_file_count} files found in the app logs directory. Moving app log files older than 1 day to archive...\n")

moved_files_count = 0

for f in app_logs_files:
    if os.path.isfile(f):
        file_time = os.path.getmtime(f)
        file_age_days = (datetime.now() - datetime.fromtimestamp(file_time)).days
        if file_age_days > 1 and ("EMS" in f or "NOTIF" in f or "Scheduler" in f or ".gz" in f):
            shutil.move(f, archive_directory)
            moved_files_count += 1

with open(log_file, "a") as log:
    log.write(f"{current_datetime} - Found and moved {moved_files_count} app log files to archive. {app_logs_file_count - moved_files_count} files remain in the app logs directory.\n")
    log.write("--------------------------------------------------------------------\n")


#### Check the number of files in the archive after the move from app_logs_dir #################################
archive_files = glob.glob(f"{archive_directory}*.*")
archive_file_count = len(archive_files)

 # If there are more than 2000 files in the archive after the move, log an error and exit
if archive_file_count > 2000:
    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - Error: Unexpectedly large amount of files present in the archive ({archive_file_count} files). Aborting archive deletion.\n")
        log.write("====================================================================\n")
    exit(1)
else:
    # Delete files with timestamps older than 7 days in the archive_directory
    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - Total of {archive_file_count} app log files found in the archive directory. Deleting files older than 7 days...\n")

    now = datetime.now()
    for f in archive_files:
        if os.path.isfile(f):
            file_time = os.path.getmtime(f)
            file_age_days = (now - datetime.fromtimestamp(file_time)).days
            if file_age_days > 7:
                os.remove(f)
                
    # Print the new number of files after deletion
    new_archive_file_count = len(glob.glob(f"{archive_directory}*.*"))

    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - Total of {new_archive_file_count} app log files left in the archive directory after deletion.\n")
        log.write("====================================================================\n")
