#!/bin/bash

TARGET_USER=$1
HOME_DIR=$(getent passwd $TARGET_USER | cut -d: -f6)

echo "$(tput setaf 2)$(tput bold)User: ${TARGET_USER}: $(tput sgr 0) -> ${HOME_DIR}"

find $HOME_DIR -maxdepth 1 -mindepth 1 -type d | while read DIR; do
    sudo chown "${TARGET_USER}": -R "${DIR}"
    sudo chown root: "${DIR}"
    echo "$(tput bold)Fixed: $(tput sgr 0) ${DIR}"
done
