#!/bin/sh

SOURCE_DUMP="$1"
TMP_DIR=$(mktemp -d)

if [ ! -f "$SOURCE_DUMP" ]; then
    echo "USAGE: restore.sh <DUMP_FILE>"
    exit 1
fi

tar xvzf "$SOURCE_DUMP" -C "$TMP_DIR"

docker cp -a "$TMP_DIR/wp" "$CONTAINER_WP":'/var/www/html'

docker exec -i "$CONTAINER_DB" \
    sh -c 'exec mysql -uroot -p"$MYSQL_ROOT_PASSWORD"' < "$TMP_DIR/dump.sql"
