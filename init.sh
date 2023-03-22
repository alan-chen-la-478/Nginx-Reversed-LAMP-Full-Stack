#!/bin/bash

. ./helpers.sh

heading 'Checking for secondary sudo user...'

USERNAME=$(wait-for "Enter a secondary admin username (default: serveradmin): " "serveradmin");

if [ $(grep -ic $USERNAME /etc/passwd) = 0 ];
then
    echo "Secondary admin $(tput bold)${USERNAME}$(tput sgr 0) not found, creating..."
    RANDOM_PASSWORD=$(openssl rand -base64 12)
    PASSWORD=$(wait-for "Enter a password (leave empty to generate random one): " $RANDOM_PASSWORD true);
    echo '';

    adduser --gecos "" --disabled-password $USERNAME ## >/dev/null 2>&1
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    usermod -aG sudo $USERNAME ## >/dev/null 2>&1

    if [ "$RANDOM_PASSWORD" = "$PASSWORD" ]; then
        USER_HOMEDIR=$(getent passwd $USERNAME | cut -d: -f6)
        USER_PASSWD_FILE=$USER_HOMEDIR/.sshpw
        echo $PASSWORD | sudo tee $USER_PASSWD_FILE ## >/dev/null 2>&1
        echo "Password Generated: $(tput bold)${USER_PASSWD_FILE}$(tput sgr 0)";
    fi

    echo "User $(tput bold)${USERNAME}$(tput sgr 0) created. continue..."
else
    echo "User $(tput bold)${USERNAME}$(tput sgr 0) already exists. continue..."
fi

if [ $(grep -ic "^pwdfree:" /etc/group) = 0 ];
then
    groupadd pwdfree
    echo "%pwdfree ALL=(ALL) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/pwdfree ## >/dev/null 2>&1
fi

usermod -aG pwdfree $USERNAME ## >/dev/null 2>&1
sudo -u $USERNAME bash ./install.sh
deluser $USERNAME pwdfree ## >/dev/null 2>&1

heading '✨ DONE!!'