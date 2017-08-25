#! /bin/bash

# example script how duply could be called
# pre/post scripts should be set up properly

export DATE=$(date +%Y-%m-%d_%H-%M-%S)

# call pre script
bash ./pre

# set up log directory
install -d -o root -m 0700 /var/log/backups/

# clean up outdated logs
find /var/log/backups -mtime +31 -print0 | xargs -0 rm || true

# make backup
echo "Call your script here" | pxz -9 > /var/log/backups/generic_backup_"$DATE".log.xz

# call post script
bash ./post
