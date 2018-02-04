#!/bin/bash

set -e
pwd
# copy oldest from dump directory
ls -lt /dump/ | grep -v '^d' | tail -1 | awk '{print $NF}' | xargs -I{} cp /dump/{} /weekly/

# prune if older than DELETE_WEEKLY_OLDER_THAN_DAYS days
if [ ! -z "$DELETE_WEEKLY_OLDER_THAN_DAYS" ]; then
	echo "Deleting old backups: $DELETE_WEEKLY_OLDER_THAN_DAYS"
	find /weekly/* -mtime "+$DELETE_WEEKLY_OLDER_THAN_DAYS" -exec rm {} \;
fi
