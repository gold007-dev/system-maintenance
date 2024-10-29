#!/bin/bash

echo $(($(systemctl --failed | wc -l) - 3)) failed packages
read -p "do you want to manually check for logged errors? [Y/n] " checkLog

if [ "$checkLog" == "Y" ] || [ "$checkLog" == "y" ]; then
    journalctl -b
fi

read -p "do you want to create a full backup? [Y/n] " fullBackup

if [ "$fullBackup" == "Y" ] || [ "$fullBackup" == "y" ]; then
    $(dirname $0)/full-backup.sh
fi

read -p "do you want to create backups? [Y/n] " backups

if [ "$backups" == "Y" ] || [ "$backups" == "y" ]; then
    $(dirname $0)/backups.sh
fi

read -p "Do you want to update the mirrorlist? [Y/n]" mirrorList

if [ "$mirrorList" == "Y" ] || [ "$mirrorList" == "y" ]; then
    read -p "What mirrors do you want? [http/https/all]" mirrors
    if [ "$mirrors" == "http" ]; then
        # https://archlinux.org/mirrorlist/all/http/
        sudo curl "https://archlinux.org/mirrorlist/all/http/" -o /etc/pacman.d/mirrorlist
        sudo sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
    elif [ "$mirrors" == "https" ]; then
        # https://archlinux.org/mirrorlist/all/https/
        sudo curl "https://archlinux.org/mirrorlist/all/https/" -o /etc/pacman.d/mirrorlist
        sudo sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
    elif [ "$mirrors" == "all" ]; then
        # https://archlinux.org/mirrorlist/all/
        sudo curl "https://archlinux.org/mirrorlist/all/" -o /etc/pacman.d/mirrorlist
        sudo sed -i 's/^#Server/Server/' /etc/pacman.d/mirrorlist
    else
        echo "invalid answer! not updating"
    fi
fi

read -p "do you want to upgrade your system? [Y/n] " upgrade

if [ "$upgrade" == "Y" ] || [ "$upgrade" == "y" ]; then
    read -p "do you want to use yay? [Y/n]" useYay
    if [ "$useYay" == "Y" ] || [ "$useYay" == "y" ]; then
        yay -Syu --noanswerclean --noanswerdiff --noconfirm
    else
        sudo pacman -Syu --noconfirm
    fi

fi

read -p "Do you want to check for unnececary dependencies? [Y/n]" dependencyCheck

if [ "$dependencyCheck" == "Y" ] || [ "$dependencyCheck" == "y" ]; then
    if [ $(command -v yay | wc -l) -gt 0 ]; then
        echo $(yay -Qtdq | wc -l) are unnececary
    else
        echo $(sudo pacman -Qtdq | wc -l) are unnececary
    fi
    read -p "Do you want to remove all unnececary dependencies? [Y/n]" removeDependencies
    if [ "$removeDependencies" == "Y" ] || [ "$removeDependencies" == "y" ]; then
        if [ $(command -v yay | wc -l) -gt 0 ]; then
            yay -R $(yay -Qtdq)
        else
            sudo pacman -R $(pacman -Qtdq)
        fi
    fi
fi

read -p "Do you want to list all broken symlinks? [Y/n] " listSymlinks
if [ "$listSymlinks" == "Y" ] || [ "$listSymlinks" == "y" ]; then
    broken="$(find / -xtype l -print 2>/dev/null)"
    echo "$broken"
    read -p "Do you want to remove all broken symlinks? [Y/n] " removeSymlinks
    if [ "$removeSymlinks" == "Y" ] || [ "$removeSymlinks" == "y" ]; then
        sudo rm -f "$broken"
    fi
fi