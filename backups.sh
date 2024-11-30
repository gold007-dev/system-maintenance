#!/bin/bash
read -p "do you want to backup your packages? [Y/n]" backupPackages

timestamp="$(date "+%Y-%m-%d.%H-%M-%S")"

if [ "$backupPackages" == "Y" ] || [ "$backupPackages" == "y" ]; then
    if [ $(command -v yay | wc -l) -gt 0 ]; then
        mkdir -p ~/backups/temp/$timestamp
        yay -Qqe >~/backups/temp/$timestamp/packages-yay.txt
    fi
    pacman -Qqe >~/backups/temp/$timestamp/packages-pacman.txt
fi

read -p "do you want to backup your config files from ~/.config? [Y/n]" backupConfig

if [ "$backupConfig" == "Y" ] || [ "$backupConfig" == "y" ]; then
    mkdir -p ~/backups/temp/$timestamp
    cp -r ~/.config/ ~/backups/temp/$timestamp
    rm ~/backups/temp/$timestamp/chromium -rf
    find ~/backups/temp/$timestamp/ | grep Cache | rm -rf
fi

read -p "do you want to backup your local pacman database? [Y/n]" pacman

if [ "$pacman" == "Y" ] || [ "$pacman" == "y" ]; then
    mkdir -p ~/backups/temp/$timestamp
    tar -cjf ~/backups/temp/$timestamp/pacman_database.tar.bz2 /var/lib/pacman/local
fi
echo "compressing backup"
if [ $(command -v 7zz | wc -l) -gt 0 ]; then
    7zz a ~/backups/$timestamp.7z ~/backups/temp/$timestamp/
elif [ $(command -v 7z | wc -l) -gt 0 ]; then
    7z a ~/backups/$timestamp.7z ~/backups/temp/$timestamp/
else
    bsdtar -cJf ~/backups/$timestamp.tar.xz ~/backups/temp/$timestamp/
fi

rm -r ~/backups/temp/$timestamp
