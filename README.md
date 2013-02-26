mysql-move-dbs-to-disk
======================

Move mysql databases to different disk.

This is usefull for hosting providers with a lot of databases. It moves a database to another disk and creates a symlink. If there is a better way of doing this, please write me a message.


This script assumes a lot of stuff, make sure you test it well before doing in in production.

MAKE A BACKUP BEFORE DOING ANYTHING TO PRODUCTION SERVERS.


Introduction
======================
This script moves database files from one busy/full disk to another empty/faster one.

Let's say we have a situation like this:
	/dev/mapper/mysql1-mysql1	99G   91G  2.9G  97% /var/lib/mysql

We want to free up some disk space, so we add another empty disk:
	/dev/mapper/mysql2-mysql2	99G  188M   94G   1% /var/lib/mysql2

Now we want to move some databases. Let's say move all databases that are bigger than 500MB OR have more than 750 tables (clearly storage abusers in the shared hosting realm :))

Edit the source code of move_dbs.sh and replace the variables

	FROMDIR="/var/lib/mysql/"
	TODIR="/var/lib/mysql2/"
	PASS="testpass" # don't forget to remove it after you use the script
	
	MAXTABLES=750 # maximum number of tables per database
	MAXSPACE=524288000 # maximum disk space in bytes

The mysql root password is needed for "FLUSH TABLES WITH READ LOCK" you can edit the script to your liking.

Now issue ./move_dbs.sh -d

It will print the databases that are going to be moved, but will not actualy move them. If you are happy with the result, just do a ./move_dbs.sh and it will start syncing.

Credits
======================
Ivan Dimitrov <https://github.com/dobber>

I don't take credit for your lost databases, make a backup before issuing anything in production.
