#!/bin/bash

# configurations
DOMAIN=domain.com
USER=account_name
WWW=true
SSH=false
SFTP=true
SSL=true
PROTECTED=false
HOME_DIR="/var/www/${USER}/"
VHOST_DIR="${DOMAIN}/"
SERVED_DIR=
DB_NAME=

# path
VHOST_PATH="${HOME_DIR}${VHOST_DIR}"
SERVED_PATH="${VHOST_PATH}public_html/${SERVED_DIR}"
. ./operations/create-path.sh

# Add User
. ./operations/create-user.sh

# pool
POOL_FILE="/etc/php/7.4/fpm/pool.d/${USER}.conf"
. ./operations/create-fpm-pool.sh

# nginx conf
CONF_FILE="/etc/nginx/sites-available/${DOMAIN}"
APACHE_FILE="/etc/apache2/sites-available/${DOMAIN}.conf"
. ./operations/create-apache-nginx-conf.sh

# database
. ./operations/create-database.sh

# reload
. ./operations/test-and-reload.sh

# Sample Files
. ./operations/create-sample-files.sh

# Let's encrypt
. ./operations/create-letsencrypt.sh

# phpmyadmin
. ./operations/create-phpmyadmin.sh

# password
. ./operations/create-protected.sh

# reload
. ./operations/test-and-reload.sh

echo "$(tput setaf 2)$(tput bold)Boom DONE\! $(tput sgr 0)"
