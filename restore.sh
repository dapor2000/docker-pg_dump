#!/bin/bash

set -e

RESTORE_FILE="/dump/${1}"
if [[ ! -e "$RESTORE_FILE" ]]; then
    echo "Unable to restore $RESTORE_FILE"
    echo "File does not exist"
    exit 1
fi

echo "Restore started: $(date)"

gunzip <$RESTORE_FILE >/dump/restore.sql

pg_restore -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -c -d "$PGDB" /dump/restore.sql

rm /dump/restore.sql

echo "Restore finished: $(date)"
