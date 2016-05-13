#!/bin/bash

script_dir=$1

cd $script_dir

# Log file
#LOG_DATE=$(date +'%Y-%m-%d-%H%M')
#exec >> $script_dir/log/$LOG_DATE.backup.log
#exec 2>&1

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

bk_psql_db ()
{
    local HOST=$1
    local USER=$2
    local NAME=$4

    if [ -n $AMBARI_SERVER_PID ]; then
        echo "Found ambari-server."
        echo "Backup DB postgress --> $NAME"
        su - postgres -c "pg_dump $NAME" > $TEMP_DIR/$NOW.$HOSTNAME.$NAME.sql

    else
        echo "ambari-server not found."
    fi
}

tar_sql_bk ()
{
    local NAME=$1
    
    echo "......creating TAR file for DB $NAME" + $(date)
    tar --create --gzip --preserve-permissions --recursion --absolute-names -f ${TEMP_DIR}/${NOW}.${HOSTNAME}.${NAME}_DB.tgz ${TEMP_DIR}/*.$NAME.sql
    echo "......finished creating the TAR file with filename "$NOW"."$HOSTNAME"."$NAME"_DB.tgz " + $(date)
    echo "......delete .sql backup files."
    rm -f ${TEMP_DIR}/*.sql
    echo "......delete ok."
}

lock_file=./bk_run.lock

bk_is_running

NOW=$(date +'%Y-%m-%d')
HOSTNAME=$(hostname)
BK_DIR=$2
DB_TYPE=$3
DB_HOST=$4
DB_USER=$5
DB_NAME=$6

TEMP_DIR=${BK_DIR}/${NOW}
AMBARI_SERVER_PID=`cat /var/run/ambari-server/ambari-server.pid | awk 'NR==1{print $1}'`
if [ -d $TEMP_DIR ]; then
    chmod 777 $TEMP_DIR
else
    mkdir $TEMP_DIR
    chmod 777 $TEMP_DIR
fi

if [[ "$DB_TYPE" == "psql" ]] ; then
    bk_psql_db $DB_HOST $DB_USER $DB_NAME
    tar_sql_bk $DB_NAME  

elif [[ "$DB_TYPE" == "mysql" ]] ; then
    echo "bk_mysql_db DB_HOST DB_USER DB_PASSWD DB_NAME"

fi

bk_remove_lock
