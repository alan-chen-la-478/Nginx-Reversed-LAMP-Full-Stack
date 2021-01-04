#!/bin/bash

# NGINX
if [ -f "$CONF_FILE" ]; then
    echo "$CONF_FILE already exists."
else
    echo "$(tput setaf 2)$(tput bold)Creating Nginx config... $(tput sgr 0)"
    sudo cp ./templates/apache-nginx-vhost.conf $CONF_FILE

    if [ "$WWW" = true ]; then
        sudo sed -i "s/# server { # WWW/server { # WWW/g" $CONF_FILE
        sudo sed -i "s/# server_name www.{{DOMAIN}}; # WWW/server_name www.${DOMAIN}; # WWW/g" $CONF_FILE
        sudo sed -i "s/# return 301 \$scheme:\/\/{{DOMAIN}}\$request_uri; # WWW/return 301 \$scheme:\/\/${DOMAIN}\$request_uri; # WWW/g" $CONF_FILE
        sudo sed -i "s/# } # WWW/} # WWW/g" $CONF_FILE
    fi

    sudo sed -i "s/{{DOMAIN}}/${DOMAIN}/g" $CONF_FILE
    sudo sed -i "s#{{SERVED_PATH}}#${SERVED_PATH}#g" $CONF_FILE
    sudo sed -i "s#{{ROOT}}#${VHOST_PATH}#g" $CONF_FILE
    sudo sed -i "s#{{SOCKET}}#/var/run/php/php7.4-fpm-${USER}.sock#g" $CONF_FILE

    echo "$CONF_FILE created."
fi

if [ ! -f "/etc/nginx/sites-enabled/${DOMAIN}" ]; then
    sudo ln -s $CONF_FILE "/etc/nginx/sites-enabled/${DOMAIN}"

    echo "Nginx: $DOMAIN enabled."
fi

# APACHE
if [ -f "$APACHE_FILE" ]; then
    echo "'$APACHE_FILE' already exists."
else
    echo "$(tput setaf 2)$(tput bold)Creating Apache config... $(tput sgr 0)"
    sudo cp ./templates/apache-vhost.conf $APACHE_FILE
    sudo sed -i "s/{{DOMAIN}}/${DOMAIN}/g" $APACHE_FILE
    sudo sed -i "s#{{SERVED_PATH}}#${SERVED_PATH}#g" $APACHE_FILE
    sudo sed -i "s#{{ROOT}}#${VHOST_PATH}#g" $APACHE_FILE
    sudo sed -i "s#{{SOCKET}}#/var/run/php/php7.4-fpm-${USER}.sock#g" $APACHE_FILE

    echo "'$APACHE_FILE' created."
fi

sudo a2ensite "${DOMAIN}"
echo "Apache: $DOMAIN enabled."

