#!/bin/bash

set -e

echo "Job started: $(date)"

DATE=$(date +%Y%m%d_%H%M%S)
FILE="/dump/$PREFIX-$DATE.sql"
# echo pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "$FILE" -d "$PGDB" -Fc
pg_dump -h "$PGHOST" -p "$PGPORT" -U "$PGUSER" -f "$FILE" -d "$PGDB" -Fc
gzip "$FILE"

# if [ -f /keys/backup.pub ]; then
# 		echo "Encrypting"
# 		echo gpg --verbose --output "$FILE".gz.gpg --yes --batch --encrypt --trust-model always --recipient "$KEY_NAME" "$FILE".gz
# 		gpg --verbose --output "$FILE".gz.gpg --yes --batch --encrypt --trust-model always --recipient "$KEY_NAME" "$FILE".gz
# 		rm "$FILE".gz
# else
# 		echo "Coulding find backup key. Not Encrypting"
# fi

if [ ! -z "$DELETE_OLDER_THAN" ]; then
	echo "Deleting old backups: $DELETE_OLDER_THAN"
	find /dump/* -mmin "+$DELETE_OLDER_THAN" -exec rm {} \;
fi

LATEST_BACKUP_DATE=$(date +%Y-%m-%dT%H:%M:%S%z)
echo $LATEST_BACKUP_DATE > /status/latest_backup_date

echo "Job finished: $(date)"
