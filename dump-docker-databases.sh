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

# create data directory
# you can change this to your liking
BACKUP_DATA_DIR="/root/backup/$DATE"
echo "Backup directory: $BACKUP_DATA_DIR"
install -d -m 0700 "$BACKUP_DATA_DIR"

# create Docker PostgreSQL SQL dumps
docker ps | grep "postgres:" | awk '{print $1}' | while read -r container; do
    container_name=$(docker inspect -f '{{.Name}}' "$container" | sed 's|/||g')
    echo "Backing up PostgreSQL dump from $container (a.k.a. $container_name)"
    docker exec "$container" pg_dumpall -U postgres | pxz > "$BACKUP_DATA_DIR"/docker-postgres-"$container"-"$container_name"-"$DATE".sql.xz
done

# create Docker MongoDB BSON dumps
docker ps | grep "mongo:" | awk '{print $1}' | while read -r container; do
    container_name=$(docker inspect -f '{{.Name}}' "$container" | sed 's|/||g')
    echo "Backing up MongoDB dump from $container (a.k.a. $container_name)"
    tempdir=$(mktemp -d -p "$BACKUP_DATA_DIR" -t "mongodump-tmp-XXXXXXXXXXX")
    docker exec "$container" mongodump -v --out=/dump-"$DATE" &>/dev/null
    docker cp "$container":"/dump-$DATE" "$tempdir"
    docker exec "$container" rm -rf /dump-"$DATE"
    (cd "$tempdir" && tar -cJf docker-mongo-"$container"-"$container_name"-"$DATE".tar.xz dump-"$DATE"/)
    mv "$tempdir"/*.tar* "$BACKUP_DATA_DIR"
    rm -rf "$tempdir"
done
