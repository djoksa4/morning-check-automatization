import os
import shutil
from datetime import datetime
import glob

#### Paths #####################################################################################################
# Define the log file path
log_file = "/home/wl12/morning-check-automatization/deletion-logs/deletion_log.log"

# Define the directory paths
gw_logs_dir = "/spimi/logs/weblogic/fcbi0gw/Gateway/"
archive_dir = "/spimi/logs/weblogic/fcbi0gw/Gateway/archive/"

#### Get the current date and time #############################################################################
current_datetime = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

#### Log the execution of the script ###########################################################################
with open(log_file, "a") as log:
    log.write(f"{current_datetime} - Script executing...\n")
    log.write("--------------------------------------------------------------------\n")


#### Archival and deletion #####################################################################################
dir_name_array = ["GWWS", "GWEJB"]

for dir_name in dir_name_array:

    # Move all the app log files older than 1 day to archive
    gw_logs_dir_path = os.path.join(gw_logs_dir, dir_name)
    gw_archive_dir_path = os.path.join(archive_dir, dir_name)

    gw_logs_files = glob.glob(f"{gw_logs_dir_path}*.*")
    gw_logs_files_count = len(gw_logs_files)
    
    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - {gw_logs_files_count} files found in the {dir_name} logs directory. Moving {dir_name} log files older than 1 day to archive...\n")

    moved_files_count = 0

    for f in gw_logs_files:
        if os.path.isfile(f):
            file_time = os.path.getmtime(f)
            file_age_days = (datetime.now() - datetime.fromtimestamp(file_time)).days
            if file_age_days > 1 and (f.endswith('.gz') or f.endswith('.log')):
                shutil.move(f, gw_archive_dir_path)
                moved_files_count += 1

    with open(log_file, "a") as log:
        log.write(f"{current_datetime} - Found and moved {moved_files_count} {dir_name} log files to archive.\n")

    # Check the number of files in the archive AFTER the move from logs dir
    archive_files = glob.glob(f"{gw_archive_dir_path}/*.*")
    archive_file_count = len(archive_files)

    # If there are more than 2000 files in the archive after the move, log an error and exit
    if archive_file_count > 2000:
        with open(log_file, "a") as log:
            log.write(f"{current_datetime} - Error: Unexpectedly large amount of files present in the {dir_name} archive ({archive_file_count} files). Aborting archive deletion.\n")
            log.write("--------------------------------------------------------------------\n")
    else:
        # Delete files with timestamps older than 7 days in the archive_directory
        with open(log_file, "a") as log:
            log.write(f"{current_datetime} - Total of {archive_file_count} log files found in the {dir_name} archive directory. Deleting files older than 7 days...\n")

        now = datetime.now()
        for f in archive_files:
            if os.path.isfile(f):
                file_time = os.path.getmtime(f)
                file_age_days = (now - datetime.fromtimestamp(file_time)).days
                if file_age_days > 7:
                    os.remove(f)

        # Print the new number of files after deletion
        new_archive_file_count = len(glob.glob(f"{gw_archive_dir_path}/*.*"))
        
        with open(log_file, "a") as log:
            log.write(f"{current_datetime} - Total of {new_archive_file_count} log files left in the {dir_name} archive directory after deletion.\n")
            log.write("--------------------------------------------------------------------\n")

with open(log_file, "a") as log:
    log.write("====================================================================\n")
