#!/bin/bash

# if [ -d "$VHOST_PATH" ]; then
#     echo "'$VHOST_PATH' already exists."
# else
#     echo "$(tput setaf 2)$(tput bold)Creating site folders... $(tput sgr 0)"
#     sudo mkdir -p $SERVED_PATH
#     sudo mkdir -p "${VHOST_PATH}logs"

#     echo "'$VHOST_PATH' folder structure created."
# fi

sudo chown "${USER}": -R "${VHOST_PATH}"
sudo chown root: "${VHOST_PATH}"
