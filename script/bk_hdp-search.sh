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

bk_HDP-SEARCH_dir ()
{
    local HDPS_DIR=`ls -lrt -d -1 /opt/* | grep -i lucidworks-hdpsearch | awk '{print $9}'`
    if [ ! -z $HDPS_DIR -a -d $HDPS_DIR ]; then
        echo "${HDPS_DIR} found."
        echo "......creating TAR file for HDP-SEARCH directory" + $(date)
        tar --create --gzip --preserve-permissions --recursion --absolute-names -f ${NOW}.${HOSTNAME}.HDP-SEARCH_dir.tgz ${HDPS_DIR}
        echo "......finished creating the TAR file with filename "${NOW}"."${HOSTNAME}".HDP-SEARCH_dir.tgz " + $(date)
    else
        echo "Directory /opt/lucidworks not found"
    fi
}

bk_HDP-SEARCH_collection ()
{
    local HDPS_DIR=`ls -lrt -d -1 /opt/* | grep -i lucidworks-hdpsearch | awk '{print $9}'`
    if [ -d $HDPS_DIR ]; then
        local HDPS_PORT=`ps -efa | grep solr | grep -v grep | awk -F '-Djetty.port=' '{print $2}' | awk '{print $1}'`
        local HDPS_COLLECTION_ARRAY=`curl 'http://${HOSTNAME}:${HDPS_PORT}/solr/admin/collections?action=LIST' | awk -F "<arr name=\"collections\">" '{print $2}' | sed 's/<str>//g' | sed 's/<\/str><\/arr>//g' | sed 's/<\/str>/,/g'`
        IFS=',' read -a HDPS_COLLECTION_ARRAY <<< "$HDPS_COLLECTION_ARRAY"
        for COLLECTION in ${HDPS_COLLECTION_ARRAY[@]}; do
            echo "Backup ${COLLECTION} to ${NOW}.${COLLECTION}.HDP-search"
            echo "curl 'http://$HOSTNAME:$SOLR_PORT/solr/$COLLECTION/replication?command=backup&name=$NOW.$COLLECTION.solr&location=$TEMP_DIR'"
#            curl 'http://$HOSTNAME:$SOLR_PORT/solr/$COLLECTION/replication?command=backup&name=$NOW.$COLLECTION.solr&location=$TEMP_DIR'
#            BK_COLLECTION_WEIGHT=`du $NOW.$COLLECTION.solr | awk '{print $1}'`
#            sleep 5
#            while true; do
#                
#                echo "......creating TAR file for $NOW.$COLLECTION.solr " + $(date)
#                tar --create --gzip --preserve-permissions --recursion --absolute-names -f $NOW.$COLLECTION.solr.tgz $NOW.$COLLECTION.solr
#                echo "......finished creating the TAR file with filename $NOW.$COLLECTION.solr.tgz " + $(date)
#            done 
        done
#        echo "......creating TAR file for SOLR directory" + $(date)
#        tar --create --gzip --preserve-permissions --recursion --absolute-names -f $NOW.$HOSTNAME.SOLR.tgz /opt/
#        echo "......finished creating the TAR file with filename "$NOW"."$HOSTNAME".SOLR.tgz " + $(date)
    else
        echo "Directory ${HDPS_DIR} not found"
    fi 
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
    bk_HDP-SEARCH_dir
else
    mkdir $TEMP_DIR
    chmod 777 $TEMP_DIR
    cd $TEMP_DIR
    bk_HDP-SEARCH_dir
fi

cd $CASA
bk_remove_lock
