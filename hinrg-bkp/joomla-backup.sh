#!/bin/sh

backupDir=/home/backup-operator/local_backups/joomla_backups
if [ "$1" == "-i" ]
then
    echo "$(date +%s) start incremental $(date)"
    lastFullName=$backupDir/$(cat $backupDir/last_full_name)
    echo "$(date +%s) last full: $lastFullName"
    mv $backupDir/current $backupDir/last
    mysqldump --extended-insert=FALSE --user=joomla --password=none joomla > $backupDir/current

    lastIndex=$(ls $lastFullName.* | cut -d '.' -f 2 | sort -g | tail -1)
    outputFile=$lastFullName.$(expr 1 + $lastIndex)
    diff  $backupDir/last $backupDir/current > $outputFile
    echo "$(date +%s) incremental done to $outputFile"
elif [ "$1" == "-f" ]
then
    echo "$(date +%s) start full $(date)"
    dateStr=$(date +%m-%d-%Y-%H-%M)
    tmpFile=jb.$RANDOM
    mysqldump --extended-insert=FALSE --user=joomla --password=none joomla > $tmpFile
    cp $tmpFile $backupDir/$dateStr.0
    mv $tmpFile $backupDir/current

    echo "$dateStr" > $backupDir/last_full_name
    echo "$(date +%s) done."
else
    echo "Unrecognized action $1"
fi
