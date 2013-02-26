#!/bin/bash
# dobber @ 2012
# move abusers to different disk

FROMDIR="/var/lib/mysql/"
TODIR="/var/lib/mysql2/"
PASS="testpass" # don't forget to remove it after you use the script

MAXTABLES=750 # maximum number of tables per database
MAXSPACE=524288000 # maximum disk space in bytes

#DO NOT EDIT BELOW THIS LINE
let TMAXTABLES=$MAXTABLES*3 # (1 table = 3 files)

function usage {
	echo "-h) --help) display this help message"
	echo "-d) --debug) don't move the databases, only show them"
	echo "no parameters) move the databases"
	echo
	echo "Before you execute the program, make sure to edit the first parameters in the script."
	exit 1
}

function error_exit {
	if [ "$?" != "0" ]; then
		echo "$1"
		exit 1
	fi
}

function move {
	database=$1
	reason=$2
	debug=$3
	echo -n "The limit of $reason for database $database is reached. Moving it... "
	if [ $debug -eq 1 ] ; then
		rsync -a $FROMDIR/$database/ $TODIR/$database/
		error_exit "Unable to sync files.\t\"rsync -a $FROMDIR/$database/ $TODIR/$database/\""

		echo "FLUSH TABLES WITH READ LOCK" | mysql -p$PASS $database

		rsync -a $FROMDIR/$database/ $TODIR/$database/
		error_exit "Unable to sync files.\t\"rsync -a $FROMDIR/$database/ $TODIR/$database/\""

		rm -r $FROMDIR/$database/
		error_exit "Unable to remove directory.\t\"rm -r $FROMDIR/$database/\""

		ln -s $TODIR/$database/ $FROMDIR/$database

		echo "UNLOCK TABLES" | mysql -p$PASS $database
		chown -R mysql.mysql $FROMDIR/$database $TODIR/$database
	fi
	echo "done"
}

case $1 in
	-h|--help)
		usage
		;;
	-d|--debug)
		DEBUG=0
		;;
	*)
		DEBUG=1
		;;
esac

echo Moving all databases that are bigger than $MAXSPACE bytes or have more than $MAXTABLES tables.
for i in `ls $FROMDIR` ; do
	# check if the file is symlink and skip it (this means it is already moved)
	if [ -h "$FROMDIR/$i" ] ; then
		continue
	fi
	# check if the file is directory and continue
	if [ -d "$FROMDIR/$i" ] ; then
		# check for tables count
		if [ `ls "$FROMDIR/$i/" | wc -l` -gt $TMAXTABLES ] ; then
			move $i "max tables" $DEBUG
			continue
		fi
		# check for disk space
		if [ `du -cb "$FROMDIR/$i/" | grep -w total | awk '{print $1}'` -gt $MAXSPACE ] ; then
			move $i "max disk space" $DEBUG
			continue
		fi
	fi
done
