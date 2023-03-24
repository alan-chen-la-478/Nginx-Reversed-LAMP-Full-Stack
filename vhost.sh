#!/bin/bash

# configurations
DOMAIN=test3.devssite.work
USER=devssite
WWW=false
SSH=false
SFTP=true
SSL=true
PROTECTED=false
HOME_DIR="/var/www/${USER}/"
VHOST_DIR="${DOMAIN}/"
SERVED_DIR=
DB_NAME=
PHP_VERSION=8.2
LETSENCRYPT_TYPE=dns
LETSENCRYPT_TOKEN=xxx
PHPMYADMIN=false
WORDPRESS=true
WORDPRESS_ADMIN=test4_devssite
WORDPRESS_EMAIL="no-reply@${DOMAIN}"

. ./helpers.sh

# Add User
. ./operations/create-user.sh

# path
VHOST_PATH="${HOME_DIR}${VHOST_DIR}"
SERVED_PATH="${VHOST_PATH}public_html/${SERVED_DIR}"
. ./operations/create-path.sh

# pool
POOL_FILE="/etc/php/${PHP_VERSION}/fpm/pool.d/${USER}.conf"
. ./operations/create-fpm-pool.sh

# nginx conf
CONF_FILE="/etc/nginx/sites-available/${DOMAIN}"
. ./operations/create-nginx-conf.sh

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

# wordpress
. ./operations/create-wordpress.sh

# reload
. ./operations/test-and-reload.sh

echo "$(tput setaf 2)$(tput bold)Boom DONE\! $(tput sgr 0)"
