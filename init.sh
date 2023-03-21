#!/bin/bash

. ./helpers.sh

heading 'Checking for secondary sudo user...'

USERNAME=$(wait-for "Enter a secondary admin username (default: serveradmin): " "serveradmin");
echo $USERNAME;

if [ $(grep -ic $USERNAME /etc/passwd) = 0 ];
then
    echo "Secondary admin ${USERNAME} not found, creating..."
    RANDOM_PASSWORD=$(openssl rand -base64 12)
    PASSWORD=$(wait-for "Enter a password (leave empty to generate random one): " RANDOM_PASSWORD true);
    echo '';

    adduser --gecos "" --disabled-password $USERNAME
    echo "$USERNAME:$PASSWORD" | sudo chpasswd
    usermod -aG sudo $USERNAME
else
    echo "serveradmin user found"

fi
