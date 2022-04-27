#!/bin/bash
# Purpose: backup nextcloud directory to USB hard disk with rsync tool. It will automatically
#          mount your hard disk to Reand & Write mode, then determine the backup mode (Deta or All),
#          at last the it will remount the hard disk into read-only mode. 
# Any one want to use it need to input parameters
#               MOUNTUUID
#               MOUNTPOINT
#               SOURCEDIR
#               DESTDIR
#               LOGFILE
# Procedures:
#   1. Set source dir and destination dir
#   2. List dest dir, if empty, go to 2.1, else 2.2
#       2.1. Sync all data to dest with name nexcloud_YYYY-MM-DD
#       2.2. List dest directory with ls -A command, and get first one as the last backup name
#       2.3. Sync nextcloud directory with --link-dest and the dir value was get from step 2.2
. ./mountAction.sh

MOUNTUUID=0d5ae66f-c33f-4e18-8b4e-c9f80735e3b7
MOUNTPOINT=/mnt/wdusb
SOURCEDIR=/home/ubuntu/nas/data
DESTDIR=/mnt/wdusb/backuptest4
TODAY=$(date +%Y-%m-%d)
LOGFILE='/home/ubuntu/nas/backup.log'
EXCLUDELIST='/srv/nextcloud/rsync_exclude.list'

mountPartition $MOUNTUUID $MOUNTPOINT

if [ ! -d $DESTDIR ]; then
    echo "----$DESTDIR does't not exist, now creating it"
    sudo mkdir $DESTDIR
    echo "----$DESTDIR creation done"
fi

LASTBACKUPDIR=${DESTDIR}/$(ls -t ${DESTDIR} | head -n 1)
TODAYDIR=${DESTDIR}/nexcloud_${TODAY}

echo "---------Date:"$TODAY" start---------"  >> $LOGFILE

echo "LASTBACKUPDIR:"$LASTBACKUPDIR  >> $LOGFILE
echo "TODAYDIR:"$TODAYDIR  >> $LOGFILE

if [ ! $(ls -S ${DESTDIR} | tail -n -1) ]; then
# if not exist, sync all
    echo "----------Start to sync all data-----------" >> $LOGFILE
    sudo rsync -avz --log-file=$LOGFILE --log-file-format='%t %f %b' --exclude-from=$EXCLUDELIST $SOURCEDIR $TODAYDIR
else
# if backup aleady exist, sync only for the increasment
    echo "Delta backup" >> $LOGFILE
    sudo rsync -avz --log-file=$LOGFILE --log-file-format='%t %f %b' --exclude-from=$EXCLUDELIST --link-dest=${LASTBACKUPDIR} $SOURCEDIR $TODAYDIR
fi
mountToReadOnly $MOUNTUUID
echo "Execution done" >> $LOGFILE

