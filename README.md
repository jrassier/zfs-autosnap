# zfs-autosnap
Take and rotate snapshots of a ZFS filesystem

## Usage
`autosnap.sh target snap_name count`
- `target`: The ZFS dataset to act on.
- `snap_name`: Base name for snapshots. This script will append a '.' and an integer indicating relative age of the snapshot.
- `count`: The number of snapshots in the snap_name.number format described above to keep at one time. Snapshots are 'demoted' on each run such that the newest snapshot ends with '.0'

## Examples
A crontab entry that looks like this:

`1 * * * * zfs-autosnap.sh tank/files hourly 4`

Will result in this script maintaining four hourly snapshots that look like this:

```
[root@box ~]# zfs list -t snapshot
NAME                  USED  AVAIL  REFER  MOUNTPOINT
tank/files@hourly.3      0      -  1.32T  -
tank/files@hourly.2      0      -  1.32T  -
tank/files@hourly.1      0      -  1.32T  -
tank/files@hourly.0      0      -  1.32T  -
```

And every hour, at one minute past the hour, this script will delete the oldest (hourly.3) snapshot, "demote" the remaining snapshots (such that hourly.2 becomes hourly.3, hourly.1 becomes hourly.2, and so on) and create a new 
hourly.0.

Note that the string 'hourly' is only a description and does not control any aspect of scheduling.

## Thanks
Thanks to [Andrew Leonard](https://andyleonard.com/), who wrote the script from which this one is derived. His work is available [here](https://andyleonard.com/2010/04/07/automatic-zfs-snapshot-rotation-on-freebsd/).

