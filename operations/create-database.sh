#!/bin/bash

if [ ! -z "$DB_NAME" ]; then
    echo "$(tput setaf 2)$(tput bold)Creating Database... $(tput sgr 0)"
    DB="${USER}_${DB_NAME}"
    sudo mysql -e "CREATE DATABASE IF NOT EXISTS \`${DB}\`;"
    echo "MySQL database: '$DB' created."
fi
