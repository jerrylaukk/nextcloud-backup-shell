#!/bin/bash
# Purpose: backup nextcloud directory to USB drive
# Procedures:
#   1. Set source dir and destination dir
#   2. List dest dir, if empty, go to 2.1, else 2.2
#       2.1. Sync all data to dest with name "nexcloud_YYYY-MM-DD"
#       2.2. List dest directory with ls -t command, and get first one as the last backup name
#       2.3. Sync nextcloud directory with --link-dest and the dir value was get from step 2.2

TODAY=$(date +%Y-%m-%d)
SOURCEDIR=/www/wwwroot/nextcloud
DESTDIR=/mnt/wdusb/ncbackup
LASTBACKUPDIR=${DESTDIR}/$(ls -t ${DESTDIR} | head -n 1)
TODAYDIR=${DESTDIR}/nexcloud_$TODAY
LOGFILE="'/srv/nextcloud/backup.log'"
EXCLUDELIST="'/srv/nextcloud/rsync_exclude.list'"


if [ ! -e $LASTBACKUPDIR ]
# if not exist, sync all
    sudo rsync -avz --exclude-from=$EXCLUDELIST $SOURCEDIR $TODAYDIR
else
# if backup aleady exist, sync only for the increasment
    sudo rsync -avz --log-file=$LOGFILE --log-file-format='%t %f %b' --exclude-from=$EXCLUDELIST --link-dest='${LASTBACKUPDIR}' $SOURCEDIR $TODAYDIR
fi

