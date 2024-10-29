#!/bin/bash
# full system backup

# Backup destination
read -p "Backup destination: " backdest

# Labels for backup name
#PC=${HOSTNAME}
pc=${HOSTNAME}
distro=arch
type=full
date="$(date "+%Y-%m-%d.%H-%M-%S")"
backupfile="$backdest/$distro-$type-$date.tar.gz"

# Exclude file location
prog=${0##*/} # Program name from filename
excdir="~/.bin/root/backup"
read -p "Exclude file location: " exclude_file

# Check if chrooted prompt.
echo -n "First chroot from a LiveCD.  Are you ready to backup? (y/n): "
read executeback

# Check if exclude file exists
if [ ! -f $exclude_file ]; then
    echo -n "No exclude file exists, continue? (y/n): "
    read continue
    if [ $continue == "n" ]; then exit; fi
fi

if [ $executeback = "y" ]; then
    # -p, --acls and --xattrs store all permissions, ACLs and extended attributes.
    # Without both of these, many programs will stop working!
    # It is safe to remove the verbose (-v) flag. If you are using a
    # slow terminal, this can greatly speed up the backup process.
    # Use bsdtar because GNU tar will not preserve extended attributes.
    bsdtar --exclude-from="$exclude_file" --acls --xattrs -cpvaf "$backupfile" /
fi
