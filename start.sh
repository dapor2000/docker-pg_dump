#!/bin/bash

set -e

COMMAND=${1:-dump}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
WEEKLY_CRON_SCHEDULE=${WEEKLY_CRON_SCHEDULE:-0 1 * * sun}
DELETE_WEEKLY_OLDER_THAN_DAYS=${DELETE_WEEKLY_OLDER_THAN_DAYS:-90}
KEY_NAME=${KEY_NAME:backup_key}
PREFIX=${PREFIX:-dump}
PGUSER=${PGUSER:-postgres}
PGDB=${PGDB:-postgres}
PGHOST=${PGHOST:-db}
PGPORT=${PGPORT:-5432}
if [[ $ECHO_CRONFILE == 1 ]]; then
  ECHO_CRONFILE=true
else
  ECHO_CRONFILE=false
fi

# import keys
# if [ -f /keys/backup.pub ]; then
#   gpg --import /keys/backup.pub
# fi

if [[ "$COMMAND" == 'dump' ]]; then
    exec /dump.sh
elif [[ "$COMMAND" == 'dump-cron' ]]; then
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='$PGUSER'\nPGDB='$PGDB'\nPGHOST='$PGHOST'\nPGPORT='$PGPORT'\nKEY_NAME='$KEY_NAME'"
    if [ -n "$PGPASSWORD" ]; then
        ## NOTE THAT THIS IS SENSITIVE TO ESCAPING CHARACTERS IN PASSWORD
        CRON_ENV="$CRON_ENV\nPGPASSWORD='$PGPASSWORD'"
    fi

    if [ ! -z "$DELETE_OLDER_THAN" ]; then
    	CRON_ENV="$CRON_ENV\nDELETE_OLDER_THAN='$DELETE_OLDER_THAN'"
    fi

    if [ ! -z "$DELETE_WEEKLY_OLDER_THAN_DAYS" ]; then
    	CRON_ENV="$CRON_ENV\nDELETE_WEEKLY_OLDER_THAN_DAYS='$DELETE_WEEKLY_OLDER_THAN_DAYS'"
    fi

    # echo -e "$CRON_ENV\n$WEEKLY_CRON_SCHEDULE /weekly.sh > $LOGFIFO 2>&1\n$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1"
    # echo -e "$CRON_ENV\n$WEEKLY_CRON_SCHEDULE /weekly.sh > $LOGFIFO 2>&1\n$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" > /cronfile.conf
    echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1\n$WEEKLY_CRON_SCHEDULE /weekly.sh > $LOGFIFO 2>&1\n" > /cronfile.conf
    crontab /cronfile.conf
    if [ $ECHO_CRONFILE = true ]; then
      crontab -l
    fi
    cron
    tail -f "$LOGFIFO"

elif [[ "$COMMAND" == 'restore' ]]; then

  exec /restore.sh $2

else
    echo "Unknown command $COMMAND"
    echo "Available commands: dump, dump-cron"
    exit 1
fi
