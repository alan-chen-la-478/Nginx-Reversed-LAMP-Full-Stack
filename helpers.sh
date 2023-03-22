#!/bin/bash

heading() {
    echo ""
    echo "$(tput setaf 2)$(tput bold)${1}$(tput sgr 0)"
}

wait-for() {
    local input
    while true; do
        # read -p "$1" input
        if [[ "$3" == true ]]; then
            read -s -p "$1" input
        else
            read -p "$1" input
        fi

        if [ -n "$input" ]; then
            echo "$input"
            break
        elif [ -n "$2" ]; then
          echo "$2"
          break
        fi
    done
}

apt-command() {
    export DEBIAN_FRONTEND=noninteractive
    export DEBIAN_PRIORITY=critical
    sudo apt --yes --quiet --option Dpkg::Options::=--force-confold --option Dpkg::Options::=--force-confdef "$@" >/dev/null 2>&1
}

apt-install() {
    apt-command install "$@"
}

apt-update() {
    apt-command update "$@"
}

apt-upgrade() {
    apt-command upgrade "$@"
}

apt-dist-upgrade() {
    apt-command dist-upgrade "$@"
}

install-php() {
    local VERSION="$1"

    apt-install php${VERSION} php${VERSION}-fpm php${VERSION}-cli php${VERSION}-mysqli php${VERSION}-curl
    apt-install php${VERSION}-bcmath php${VERSION}-zip php${VERSION}-mbstring php${VERSION}-xml php${VERSION}-imap
    apt-install php${VERSION}-gd php${VERSION}-imagick
    apt-install php${VERSION}-memcached php${VERSION}-opcache
}