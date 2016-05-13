#!/bin/bash

# Log file
#LOG_DATE=$(date +'%Y-%m-%d-%H%M')
#exec >> ../log/$LOG_DATE.backup.log
#exec 2>&1

# Funzioni

bk_is_running ()
{
    is_run="yes"

    while [ -e $lock_file ]
    do
        sleep 5
    done

    touch $lock_file
    echo "I'm running" >> $lock_file
}

bk_remove_lock ()
{
    rm -f $lock_file
}

## etc

bk_ETC ()
{
    echo "......creating TAR file for /etc and children" + $(date)
    tar --create --gzip --preserve-permissions --recursion --absolute-names -f $NOW.$HOSTNAME.etc.tgz /etc/
    echo "......finished creating the TAR file with filename "$NOW"."$HOSTNAME".etc.tgz " + $(date)
}

lock_file=./bk_run.lock
CASA=$(pwd)

bk_is_running

NOW=$(date +'%Y-%m-%d')
HOSTNAME=$(hostname)
BK_DIR=$1

TEMP_DIR=${BK_DIR}/${NOW}

if [ -d $TEMP_DIR ]; then
    chmod 777 $TEMP_DIR
    cd $TEMP_DIR
    bk_ETC
else
    mkdir $TEMP_DIR
    chmod 777 $TEMP_DIR
    cd $TEMP_DIR
    bk_ETC
fi

cd $CASA
bk_remove_lock
