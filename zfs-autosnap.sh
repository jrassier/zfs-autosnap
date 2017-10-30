#!/usr/bin/env bash

# Paths to the executables we'll need
ZFS=/sbin/zfs
GREP=/usr/bin/grep
CUT=/usr/bin/cut
AWK=/usr/bin/awk
SORT=/usr/bin/sort
SLEEP=/bin/sleep
LOGGER=/usr/bin/logger
BASENAME=/usr/bin/basename

# The log facility and priority that we should write to
LOGFAC="user.notice"

# You shouldn't have to change anything past here
#################################################

function usage
{
    scriptname=$(${BASENAME} $0)
    echo "$scriptname: Take and rotate snapshots on a ZFS file system"
    echo
    echo "  Usage:"
    echo "  $scriptname target snap_name count"
    echo
    echo "  target:    ZFS file system to act on"
    echo "  snap_name: Base name for snapshots, to be followed by a '.' and"
    echo "             an integer indicating relative age of the snapshot"
    echo "  count:     Number of snapshots in the snap_name.number format to"
    echo "             keep at one time.  Newest snapshot ends in '.0'."
    echo
    echo "  This edition (C) 2017 Jerry Rassier"
    echo "  Adapted from https://andyleonard.com/2010/04/07/automatic-zfs-snapshot-rotation-on-freebsd/"
    echo "  Mr. Leonard's blog does not appear to provide license terms for the original script."
    echo
    exit
}

function writeLog
{
  ${LOGGER} -p ${LOGFAC} -t zfs-autosnap "$1"
}
function demoteSnap
{
  oldNum=$1
  newNum=$(($1+1))
  demoteCmd="${ZFS} rename -r ${TARGET}@${SNAP}.${oldNum} ${TARGET}@${SNAP}.${newNum}"

  writeLog "Demoting $oldNum to $newNum - executing [${demoteCmd}]"
  ${demoteCmd}
  ${SLEEP} 1
}

function deleteSnap
{
  deleteCmd="${ZFS} destroy -r ${TARGET}@${SNAP}.$1"
  writeLog "Deleting ${SNAP} snapshot $1 - executing [${deleteCmd}]"
  ${deleteCmd}
  ${SLEEP} 1
}

function createSnap
{
  createCmd="${ZFS} snapshot -r ${TARGET}@${SNAP}.$1"
  writeLog "Creating ${SNAP} snapshot $1 - executing [${createCmd}]"
  ${createCmd}
  ${SLEEP} 1
}

TARGET=$1
SNAP=$2
COUNT=$3

# Basic argument checks:
if [ -z $COUNT ] ; then
    usage
fi

if [ ! -z $4 ] ; then
    usage
fi

max_snap_desired=$(($COUNT - 1))

${ZFS} list -t snapshot | ${GREP} -F ${TARGET}@${SNAP} | ${CUT} -d'.' -f2 | ${AWK} '{print $1}' | ${SORT} -r | while read -r line ; do
  if [ ${line} -ge ${max_snap_desired} ] ; then
    deleteSnap ${line}
  else
    demoteSnap ${line}
  fi
done

createSnap 0
