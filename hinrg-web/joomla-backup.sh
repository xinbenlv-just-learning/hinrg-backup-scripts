#!/bin/sh

#This script backups joomla database 

LABEL=$(date +%Y-%m-%d-%H%M)
ts=$(date +%s)
settingsFile=$(dirname $0)/settings
. $settingsFile

if [ "$1" == "-i" ]
then
    echo "$(date +%s) start incremental $(date)"
    lastFullName=$JOOMLA_DB_BKPDIR/$(cat $JOOMLA_DB_BKPDIR/last_full_name)
    echo "$(date +%s) last full: $lastFullName"
    mv $JOOMLA_DB_BKPDIR/current $JOOMLA_DB_BKPDIR/last
    mysqldump --extended-insert=FALSE --user=joomla --password=none joomla > $JOOMLA_DB_BKPDIR/current

    lastIndex=$(ls $lastFullName.* | cut -d '.' -f 2 | sort -g | tail -1)
    outputFile=$lastFullName.$(expr 1 + $lastIndex)
    diff  $JOOMLA_DB_BKPDIR/last $JOOMLA_DB_BKPDIR/current > $outputFile
    echo "$(date +%s) incremental done to $outputFile"
elif [ "$1" == "-f" ]
then
    echo "$(date +%s) start full $(date)"
    dateStr=$(date +%m-%d-%Y-%H-%M)
    tmpFile=jb.$RANDOM
    mysqldump --extended-insert=FALSE --user=joomla --password=none joomla > $tmpFile
    cp $tmpFile $JOOMLA_DB_BKPDIR/$dateStr.0
    mv $tmpFile $JOOMLA_DB_BKPDIR/current

    echo "$dateStr" > $JOOMLA_DB_BKPDIR/last_full_name
    echo "$(date +%s) done."
else
    echo "Unrecognized action $1"
fi
