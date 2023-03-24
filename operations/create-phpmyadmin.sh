#!/bin/bash

if [ "$PHPMYADMIN" = true ] ; then
    sudo rm -rf $SERVED_PATH/*

    PHPMYADMIN_VERSION=$(curl -s https://www.phpmyadmin.net/downloads/ | grep -o -E 'phpMyAdmin-[0-9]+\.[0-9]+\.[0-9]+' | head -n 1 | cut -c 12-)
    echo "$(tput setaf 2)$(tput bold)Installing phpMyAdmin... $(tput sgr 0)"
    phpmyadminLocation="https://files.phpmyadmin.net/phpMyAdmin/${PHPMYADMIN_VERSION}/phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages.zip"
    phpmyadminFolderName="phpMyAdmin-${PHPMYADMIN_VERSION}-all-languages"

    sudo wget $phpmyadminLocation -O phpmyadmin.zip
    sudo unzip -q phpmyadmin.zip -d phpmyadmin
    sudo rm phpmyadmin.zip

    sudo mv phpmyadmin/$phpmyadminFolderName/* "${SERVED_PATH}"
    sudo rm -Rf phpmyadmin
fi
