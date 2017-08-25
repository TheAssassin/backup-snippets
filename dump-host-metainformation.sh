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

# create data directory
# you can change this to your liking
BACKUP_DATA_DIR="/root/backup/$DATE"
echo "Backup directory: $BACKUP_DATA_DIR"
install -d -m 0700 "$BACKUP_DATA_DIR"

echo "Backing up list of installed packages"
dpkg -l 2>&1 | pxz > "$BACKUP_DATA_DIR"/dpkg-list-"$DATE".txt.xz

echo "Backing up list of all Docker containers"
docker ps -a 2>&1 | pxz > "$BACKUP_DATA_DIR"/docker-containers-"$DATE".txt.xz

echo "Backing up list of all Docker images"
docker images 2>&1 | pxz > "$BACKUP_DATA_DIR"/docker-images-"$DATE".txt.xz
