# Backup Snippets

This repository provides a collection of scripts that might come in handy for
backing up data on Linux systems, or rather servers.

The scripts are intended to be used in a `pre` hook. Many backup solutions like
duply provide such hooks, otherwise you will have to call them from your cron
script or something like that.

Beware that the scripts *create* data on the filesystem. After having it backed
up, it should be deleted again. This can be achieved with a `post` hook that
deletes the backup data directory. An example `pre` and `post` hook can be
found among the actual scripts.

For the latter to work properly, the scripts expect an environment variable
`DATE` to be set, which is taken into account for creating a proper backup
data directory. By exporting this value before calling the scripts, all
backup scripts will share the same directory during a single run.

There are several Docker related snippets that dump data from several services
such as database systems. As with backups from actual servers in production,
backing up the raw files of these services can be problematic, as for busy
servers, since the files won't be captured at once, the backed up directory
is most likely corrupt in some way. Thus, most admins tend to creating
database dumps with tools like mysqldump, pg_dumpall etc. These can be used
in containers as well, but it may be complicated to do that automatically.
Thus, the repository contains a few reusable snippets, which serve as an
example for how a backup script might look like.

Then, there's a few scripts which back up essential data that can come in
handy in case of a total system failure (e.g. HDD failure). For example,
dpkg is called to get a list of packages which can then be re-installed with
the correct version when the new HDD is installed, to have a clean
installation before re-importing the backed up data (database files,
configuration data etc.). This is a better approach
than trying to restore the whole disk backup and hoping for the best.

Most data is compressed with pxz for optimized file size. As most deduplicating
backup solutions (such as borg) only consider the file metadata but not the
actual contents (resulting in them backing up the whole file instead of the
modified blocks), this will slightly optimize the whole process. Thus, make
sure pxz is installed, or replace it with another tool (e.g. pigz, pbzip2, or
the classics xz, gzip, bzip2).

Beware that backup script logs might become quite large over time, so it's
recommended to compress them as well.

If possible, think about moving the temporary directories of your backup
scripts into a RAM disk, e.g. `/dev/shm`. That will further reduce the disk
usage, which is always a plus. Note that you need a sufficient amount of free
RAM. E.g., if you're using something like duplicity which creates chunks of
the archives it creates, you need to make sure that at least one of the chunks
fits into your RAM disk. The same goes for any kind of cache directory. Talking
about cache directories, you should not include them into your backups. They
just contain local copies of metadata (and maybe even the temporary chunk files
before they're uploaded), which should really not go into any kind of backup.
For duply, the cache directory is `/root/.cache/duplicity/` if not changed, the
temporary directory needs to be looked up in the configuration file.


## License

These snippets do not contain any confidential data, and there's no real
value other than saving another admin's ass. Thus, the files are licensed
under the terms of the Creative Commons CC-0 license. A copy of this license
can be found in the LICENSE.txt file that comes with this repository, as well
as from the
[CC-0 homepage](https://creativecommons.org/publicdomain/zero/1.0/legalcode).

All we ask you to keep in mind is to share your solutions with us, maybe by
contributing your snippets to this repository. Oh, and if you find time, please
share the link, as you might make another admin's day by doing so.


## Disclaimer

As mentioned in the license, these scripts come with no warranties at all.
The author(s) do not claim that the scripts work, and they ask you to
**read** and **understand** what they do before they're used in production.

Furthermore, you are encouraged to actually **verify** the functionality of
all your own backup scripts before relying on them in production. A backup
can only be considered when restoring works fine. You should test that from
time to time.

Another tip from the author(s) is that you should implement two independent
solutions, e.g. a combination of duplicity (maybe with duply as a frontend)
and borg, using two independent off-site backup locations. Synchronizing
one backup to another location will work in most cases, but is less reliable
compared to two independent backups, as if the first backup has a failure
(for instance, a bit flip or a filled up disk), the second one will most
likely break as well. This kind of back up system can only protect from
disk failures or data loss if one location goes down.
