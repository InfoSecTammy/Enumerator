#!/bin/bash

# Create Python script
cat <<EOF > system_info_export.py
import os
import subprocess

# Helper function to execute a shell command and save the output to a file
def execute_and_save(command, output_file):
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    with open(output_file, 'w') as f:
        f.write(result.stdout)

# 1. List all running processes and export to a text file
execute_and_save('ps aux', 'running_processes.txt')

# 2. List all files in specified directories and export to a text file
directories = ['./', '/', '/usr/bin', '/bin', '/etc']
with open('files_list.txt', 'w') as f:
    for directory in directories:
        result = subprocess.run(f'ls -lah {directory}', shell=True, capture_output=True, text=True)
        f.write(f"Listing of {directory}:\n")
        f.write(result.stdout + "\n\n")

# 3. Export all environment variables to a text file
execute_and_save('printenv', 'environment_variables.txt')

# 4. Export all cron jobs to a text file
with open('cron_jobs.txt', 'w') as f:
    # System-wide cron jobs
    result = subprocess.run('cat /etc/crontab', shell=True, capture_output=True, text=True)
    f.write("System-wide cron jobs (/etc/crontab):\n")
    f.write(result.stdout + "\n\n")

    # Cron jobs for all users
    users = [user.split(':')[0] for user in open('/etc/passwd').readlines()]
    for user in users:
        cron_file = f'/var/spool/cron/crontabs/{user}'
        if os.path.exists(cron_file):
            result = subprocess.run(f'cat {cron_file}', shell=True, capture_output=True, text=True)
            f.write(f"Cron jobs for user {user}:\n")
            f.write(result.stdout + "\n\n")

# 5. Export netstat output to a text file
execute_and_save('netstat -a', 'netstat_output.txt')

# 6. Find SUID and SGID files and export to a text file
execute_and_save('find / -type f \\( -perm -4000 -o -perm -2000 \\) -ls', 'suid_sgid_files.txt')
EOF

# Run the Python script
python3 system_info_export.py

# Cleanup
rm system_info_export.py

echo "All tasks completed and output files are saved in the current directory."
