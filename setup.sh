#!/bin/bash

# install serveradmin user
echo "$(tput setaf 2)$(tput bold)Checking for secondary sudo user... $(tput sgr 0)"
SERVERADMIN_EXISTS=$(grep -ic "serveradmin" /etc/passwd)
if [ $SERVERADMIN_EXISTS = 0 ];
then
    echo "serveradmin user not found, creating..."
    adduser --gecos "" serveradmin
    usermod -aG sudo serveradmin
fi

PWDFREE_GROUP_EXISTS=$(grep -ic "^pwdfree:" /etc/group)
if [ $PWDFREE_GROUP_EXISTS = 0 ];
then
    groupadd pwdfree
fi

su serveradmin

# echo "$(tput setaf 2)$(tput bold)Switching to secondary sudo user... $(tput sgr 0)"
# sudo cp ./stubs/pwdfree.conf /etc/sudoers.d/pwdfree
# usermod -aG pwdfree serveradmin
# su -p serveradmin
# cd ~

# # echo "$(tput setaf 2)$(tput bold)Pulling installation repo... $(tput sgr 0)"
# # git pull https://github.com/alan-chen-la-478/Nginx-Reversed-LAMP-Full-Stack.git server-setup
# # cd server-setup

# sudo bash install.sh

# sudo -i
# deluser serveradmin pwdfree
