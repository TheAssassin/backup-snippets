#! /bin/bash

if [ "$DATE" == "" ]; then
    echo "Fatal: DATE not set!"
    exit 1
fi

# uses pxz (parallelized implementation of xz) by default
# replace all "pxz" occurrences to use another compression technology, like pigz or pbzip2
if ! type pxz &>/dev/null; then
    echo "Fatal: pxz not found!"
    exit 1
fi

DATE=$(date +%Y-%m-%d_%H-%M-%S)

# check whether there's a .my.cnf in the root directory so that a connection can be set up without asking the user for a password
if [ ! -f /root/.my.cnf ]; then
    echo "Fatal: /root/.my.cnf does not exist! Logging into MariaDB/MySQL won't work!"
    echo "Please create that file, and make sure it works by calling e.g. sudo -H mysql!"
    exit 1
fi

# create data directory
# you can change this to your liking
BACKUP_DATA_DIR="/root/backup/$DATE"
echo "Backup directory: $BACKUP_DATA_DIR"
install -d -m 0700 "$BACKUP_DATA_DIR"

echo "Backing up host MySQL dump"
mysqldump --all-databases -u root | pxz > "$BACKUP_DATA_DIR"/mysqldump-"$DATE".sql.xz

echo "Backing up host PostgreSQL dump"
# suppress warnings by cd-ing into /tmp
(cd /tmp && sudo -u postgres pg_dumpall | pxz) > "$BACKUP_DATA_DIR"/pgsqldump-"$DATE".sql.xz
