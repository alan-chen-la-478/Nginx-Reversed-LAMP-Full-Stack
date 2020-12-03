#!/bin/bash

if [ -z "$DB_NAME" ]; then
    DB="${USER}_${DB_NAME}"
    sudo mysql -e "create database ${DB};"
    echo "MySQL database: '$DB' created."
fi
