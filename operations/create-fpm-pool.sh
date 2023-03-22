#!/bin/bash

if [ -f "$POOL_FILE" ]; then
    echo "'$POOL_FILE' already exists."
else
    echo "$(tput setaf 2)$(tput bold)Creating fpm pool file... $(tput sgr 0)"
    sudo cp ./stubs/fpm-pool.conf $POOL_FILE
    sudo sed -i "s/{{USER}}/${USER}/g" $POOL_FILE
    sudo sed -i "s/{{PHP_VERSION}}/${PHP_VERSION}/g" $POOL_FILE

    echo "'$POOL_FILE' created."
fi
