#!/bin/bash

if [ "$SSL" = true ] ; then
    echo "$(tput setaf 2)$(tput bold)Creating SSL certificates... $(tput sgr 0)"

    if [ "$LETSENCRYPT_TYPE" = 'http' ] ; then
        sudo certbot certonly --nginx -d ${DOMAIN} --agree-tos

        if [ "$WWW" = true ]; then
            sudo certbot certonly --nginx -d "www.${DOMAIN}" --agree-tos
        fi
    fi

    if [ "$LETSENCRYPT_TYPE" = 'dns' ] ; then
        LETSENCRYPT_INI_FILE="${VHOST_PATH}letsencrypt-${DOMAIN}.ini"
        sudo cp ./stubs/cloudflare.ini $LETSENCRYPT_INI_FILE
        sudo chown root: $LETSENCRYPT_INI_FILE
        sudo chmod 600 $LETSENCRYPT_INI_FILE
        sudo sed -i "s/{{TOKEN}}/${LETSENCRYPT_TOKEN}/g" $LETSENCRYPT_INI_FILE

        sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials $LETSENCRYPT_INI_FILE -d ${DOMAIN} --agree-tos

        if [ "$WWW" = true ]; then
            sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials $LETSENCRYPT_INI_FILE -d "www.${DOMAIN}" --agree-tos
        fi
    fi

    # redirect
    sudo sed -i "s/# server { # SSL/server { # SSL/g" $CONF_FILE
    sudo sed -i "s/# listen 80; # SSL/listen 80; # SSL/g" $CONF_FILE
    sudo sed -i "s/# server_name ${DOMAIN}; # SSL/server_name ${DOMAIN}; # SSL/g" $CONF_FILE
    sudo sed -i "s/# return 301 https:\/\/\$server_name\$request_uri; # SSL/return 301 https:\/\/\$server_name\$request_uri; # SSL/g" $CONF_FILE
    sudo sed -i "s/# } # SSL/} # SSL/g" $CONF_FILE

    # certificates
    sudo sed -i "s/listen 80; # HTTP/# listen 80; # HTTP/g" $CONF_FILE
    sudo sed -i "s/# listen 443 /listen 443 /g" $CONF_FILE
    sudo sed -i "s/# ssl_certificate /ssl_certificate /g" $CONF_FILE
    sudo sed -i "s/# ssl_certificate_key /ssl_certificate_key /g" $CONF_FILE
    sudo sed -i "s/# ssl_trusted_certificate /ssl_trusted_certificate /g" $CONF_FILE
    sudo sed -i "s/# include snippets\/nginx-ssl.conf/include snippets\/nginx-ssl.conf/g" $CONF_FILE

    retest
    reload

    echo "'SSL Certivicates' created."
fi
