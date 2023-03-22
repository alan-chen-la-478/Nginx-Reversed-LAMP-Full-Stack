#!/bin/bash

LETSENCRYPT_EMAIL=
LETSENCRYPT_TOKEN=

LETSENCRYPT_INI_FILE=/etc/letsencrypt/cloudflare.ini
sudo cp ./stubs/cloudflare.ini $LETSENCRYPT_INI_FILE
sudo chown root: $LETSENCRYPT_INI_FILE
sudo chmod 600 $LETSENCRYPT_INI_FILE
sudo sed -i "s/{{EMAIL}}/${LETSENCRYPT_EMAIL}/g" $LETSENCRYPT_INI_FILE
sudo sed -i "s/{{TOKEN}}/${LETSENCRYPT_TOKEN}/g" $LETSENCRYPT_INI_FILE

sudo certbot certonly --dns-cloudflare --dns-cloudflare-credentials /etc/letsencrypt/cloudflare.ini -d yourdomain.com -d *.yourdomain.com
