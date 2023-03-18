#!/bin/sh

SOURCE_DUMP="$1"
TMP_DIR=$(mktemp -d)

if [ ! -f "$SOURCE_DUMP" ]; then
    echo "USAGE: restore.sh <DUMP_FILE>"
    exit 1
fi


CONTAINER_DB=$(docker container ls | grep 'wordpress_db' | awk '{ print $1 }')
CONTAINER_WP=$(docker container ls | grep 'wordpress_wordpress' | awk '{ print $1 }')

tar xvzf "$SOURCE_DUMP" -C "$TMP_DIR"

docker cp -a "$TMP_DIR/wp" "$CONTAINER_WP":'/var/www/html'

docker exec -i "$CONTAINER_DB" \
    sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$TMP_DIR/dump.sql"
