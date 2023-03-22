#!/bin/bash

if [ "$WORDPRESS" = true ] ; then
    sudo rm -rf $SERVED_PATH/*

    DB_USERNAME=$(awk -F'=' '/^\[client\]/{a=1} a==1 && $1=="user" {print $2; exit}' "$HOME_DIR.my.cnf")
    DB_PASSWORD=$(awk -F'=' '/^\[client\]/{a=1} a==1 && $1=="password" {print $2; exit}' "$HOME_DIR.my.cnf")
    WORDPRESS_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

    sudo wp core download --path=$SERVED_PATH --allow-root
    sudo wp core config --path=$SERVED_PATH --dbname=$DB_NAME --dbuser=$DB_USERNAME --dbpass=$DB_PASSWORD --allow-root
    sudo wp core install --path=$SERVED_PATH --url="https://{$DOMAIN}" --title="Site Title" --admin_user=$WORDPRESS_ADMIN --admin_password=$WORDPRESS_PASSWORD --admin_email=$WORDPRESS_EMAIL --allow-root

    sudo chown "${USER}": -R "${SERVED_PATH}"
    sudo chown root: "${SERVED_PATH}"

    echo "Latest Wordpress installed."
fi
