#! /bin/bash

if [ "$DATE" == "" ]; then
    echo "Fatal: DATE not set!"
    exit 1
fi

BACKUP_DATA_DIR="/root/backup/$DATE"

[ -d "$BACKUP_DATA_DIR" ] && rm -rf "$BACKUP_DATA_DIR"
