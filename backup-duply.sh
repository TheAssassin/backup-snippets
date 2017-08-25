#! /bin/bash

# example script how duply could be called
# pre/post scripts should be set up properly in duply's conf file

# make sure we terminate in case of errors
# this should ideally trigger a mail from cron to your root user
set -e

export DATE=$(date +%Y-%m-%d_%H-%M-%S)

# set up log directory
install -d -o root -m 0700 /var/log/backups/

# clean up outdated logs
find /var/log/backups -mtime +31 -print0 | xargs -0 rm || true

# perform backup, then clean up outdated ones
# you should not clean before making a backup, because if the backup command fails, you still got the old one in case you need it
duply full backup 2>&1             | pxz -9 > /var/log/backups/duply_myconfig_backup_"$DATE".log.xz
duply full purge --force 2>&1      | pxz -9 > /var/log/backups/duply_myconfig_purge_"$DATE".log.xz
duply full purge-full --force 2>&1 | pxz -9 > /var/log/backups/duply_myconfig_purge-full_"$DATE".log.xz
