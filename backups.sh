#!/bin/bash

BACKUPDIR=~/Backup 
SCRIPTDIR=~/Desktop/Bash\ Scripts
BACKUPFILE=scripts.backup.`date +%F`.tgz
BACKUPHOST=192.168.10.20
THRESHOLD=7

checkbackupdir()
{
if [ ! -d $BACKUPDIR ]; then
	echo Creating backup directory
	mkdir $BACKUPDIR
	COUNT=0
elif [ ! -e $BACKUPDIR/scripts.* ]; then
	COUNT=0
else
	COUNT=`ls $BACKUPDIR/scripts.* | wc -l`
fi
}

backup()
{
if [ $COUNT -le $THRESHOLD ]; then

	tar cvzf $BACKUPDIR/$BACKUPFILE  "$SCRIPTDIR" > /dev/null
	if [ $? != 0 ]; then echo Problems Creating Backups; fi

	scp $BACKUPDIR/$BACKUPFILE $BACKUPHOST:
	if [ $? != 0 ]; then echo Cannot Connect To Remote Host; fi
fi
}

checkbackupdir
backup


