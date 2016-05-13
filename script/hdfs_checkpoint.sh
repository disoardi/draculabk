#!/bin/bash

script_dir=$1

cd $script_dir

# Log file
#LOG_DATE=$(date +'%Y-%m-%d-%H%M')
#exec >> script_dir/log/$LOG_DATE.backup.log
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


## Start process

bk_is_running

NOW=$(date +'%Y-%m-%d')
HOSTNAME=$(hostname)
BK_DIR=$1
PATH_NAMENODE_DIR=$2

TEMP_DIR=${BK_DIR}/${NOW}
lock_file=./bk_run.lock

if [ -d $TEMP_DIR ]; then
    chmod 777 $TEMP_DIR
    cd $TEMP_DIR
else
    mkdir $TEMP_DIR
    chmod 777 $TEMP_DIR
    cd $TEMP_DIR
fi

# The resulting file contains a complete block map of the file system.
su - hdfs -c "hdfs fsck / -files -blocks -locations > dfs-old-fsck-1.log"

# Create a list of all the DataNodes in the cluster.
su - hdfs -c "hdfs dfsadmin -report > dfs-old-report-1.log"

# Capture the complete namespace of the file system.
su - hdfs -c "hdfs dfs -ls -R / > dfs-old-lsr-1.log"

# Save the namespace

## Enter in Safe Mode

su - hdfs -c "hdfs dfsadmin -safemode enter"

## Save

su - hdfs -c "hdfs dfsadmin -saveNamespace"

## Copy the checkpoint files located in ${dfs.namenode.name.dir}/current into a backup directory

cp -r ${dfs.namenode.name.dir}/current ${TEMP_DIR}

cp ${dfs.namenode.name.dir}/current/VERSION ${TEMP_DIR}

## Exit from Safe Mode

su - hdfs -c "hdfs dfsadmin -safemode leave"

# Finalize any prior HDFS upgrade

su - hdfs -c "hdfs dfsadmin -finalizeUpgrade"

bk_remove_lock
