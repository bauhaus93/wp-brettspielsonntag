#!/bin/sh

TMP_DIR=$(mktemp -d)
BACKUP_DIR="$PWD/backup"
BACKUP_FILE="$BACKUP_DIR/$(date +%Y_%m_%d)_$(uuidgen).tar.gz"
SQL_DUMP_FILE="$TMP_DIR/dump.sql"
  
CONTAINER_DB=$(docker container ls | grep 'wordpress_db' | awk '{ print $1 }')
CONTAINER_WP=$(docker container ls | grep 'wordpress_wordpress' | awk '{ print $1 }')

mkdir -p "$BACKUP_DIR"


docker exec "$CONTAINER_DB" \
    sh -c 'exec mysqldump --all-databases -uroot -p"$MYSQL_ROOT_PASSWORD"' > "$SQL_DUMP_FILE"

docker cp -a "$CONTAINER_WP":'/var/www/html' "$TMP_DIR/wp"

tar czf "$BACKUP_FILE" -C "$TMP_DIR" .
echo "Created backup file '$BACKUP_FILE', size=$(ls -lh $BACKUP_FILE | awk '{ print $5 }')"

