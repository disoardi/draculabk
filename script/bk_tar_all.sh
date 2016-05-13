#!/bin/bash

# Log file
#LOG_DATE=$(date +'%Y-%m-%d-%H%M')
#exec >> $LOG_DATE.backup.log
#exec 2>&1

lock_file=./bk_run.lock
CASA=$(pwd)

bk_is_running

NOW=$(date +'%Y-%m-%d')
HOSTNAME=$(hostname)
BK_DIR=$1

TEMP_DIR=${BK_DIR}/${NOW}

if [ -d $TEMP_DIR ]; then
    cd $TEMP_DIR
    echo "......creating TAR file for all backup file " + $(date)
    tar --create --preserve-permissions --recursion --absolute-names -f $NOW.$HOSTNAME.all_backup.tar *.tgz
    echo "......finished creating the TAR file with filename "$NOW"."$HOSTNAME".all_backup.tar " + $(date)
else
    echo "Nothing to do -.-"
fi

cd $CASA
bk_remove_lock
