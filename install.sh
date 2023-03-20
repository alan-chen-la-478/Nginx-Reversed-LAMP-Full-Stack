#!/bin/bash

# check ubuntu version and prump sudo
echo "$(tput setaf 2)$(tput bold)Prepare to start... $(tput sgr 0)"
lsb_release -a

# # update ubuntu
# echo "$(tput setaf 2)$(tput bold)Update Ubuntu... $(tput sgr 0)"
# apt-get -y update
# apt-get -y upgrade
# apt-get -y dist-upgrade
# apt install -y update-manager-core
# do-release-upgrade -f DistUpgradeViewNonInteractive
