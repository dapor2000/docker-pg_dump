#!/bin/bash

set -e

COMMAND=${1:-dump}
CRON_SCHEDULE=${CRON_SCHEDULE:-0 1 * * *}
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

if [[ "$COMMAND" == 'dump' ]]; then
    exec /dump.sh
elif [[ "$COMMAND" == 'dump-cron' ]]; then
    LOGFIFO='/var/log/cron.fifo'
    if [[ ! -e "$LOGFIFO" ]]; then
        mkfifo "$LOGFIFO"
    fi
    CRON_ENV="PREFIX='$PREFIX'\nPGUSER='$PGUSER'\nPGDB='$PGDB'\nPGHOST='$PGHOST'\nPGPORT='$PGPORT'"
    if [ -n "$PGPASSWORD" ]; then
        ## NOTE THAT THIS IS SENSITIVE TO ESCAPING CHARACTERS IN PASSWORD
        CRON_ENV="$CRON_ENV\nPGPASSWORD='$PGPASSWORD'"
    fi

    if [ ! -z "$DELETE_OLDER_THAN" ]; then
    	CRON_ENV="$CRON_ENV\nDELETE_OLDER_THAN='$DELETE_OLDER_THAN'"
    fi

    echo -e "$CRON_ENV\n$CRON_SCHEDULE /dump.sh > $LOGFIFO 2>&1" | crontab -
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
