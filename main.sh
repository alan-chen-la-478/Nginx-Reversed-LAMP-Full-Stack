#!/bin/bash

# check ubuntu version
echo "$(tput setaf 2)$(tput bold)Prepare to start... $(tput sgr 0)"
sudo lsb_release -a

# update ubuntu
sudo apt-get -y update
sudo apt-get -y upgrade
sudo apt-get -y dist-upgrade
sudo apt install -y update-manager-core
sudo do-release-upgrade -f DistUpgradeViewNonInteractive

# secondary user
# echo "$(tput setaf 2)$(tput bold)Setup secondary sudo user... $(tput sgr 0)"
# sudo adduser --gecos "" serveradmin
# sudo usermod -aG sudo serveradmin

# update server
echo "$(tput setaf 2)$(tput bold)Update apt repositories... $(tput sgr 0)"
sudo apt-get install -y software-properties-common
# sudo add-apt-repository -y ppa:nginx/development
# sudo add-apt-repository -y ppa:ondrej/php
# sudo add-apt-repository -y ppa:ondrej/apache2
# sudo add-apt-repository -y ppa:chris-lea/redis-server
# sudo add-apt-repository -y main
# sudo add-apt-repository -y universe
# sudo add-apt-repository -y restricted
# sudo add-apt-repository -y multiverse

sudo apt-get -y update
sudo apt-get -y upgrade

# swap file for low memory server
echo "$(tput setaf 2)$(tput bold)Create swap 1G file... $(tput sgr 0)"

if [ -f /swapfile ]; then
    echo "'/swapfile' already exists."
else
    sudo fallocate -l 1G /swapfile
    sudo chmod 600 /swapfile
    sudo mkswap /swapfile
    sudo swapon /swapfile
    sudo swapon --show
    sudo cp /etc/fstab /etc/fstab.bak
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
fi

# fail 2 ban
echo "$(tput setaf 2)$(tput bold)Install securities... $(tput sgr 0)"
sudo apt-get -y install fail2ban unattended-upgrades landscape-common net-tools

# firewall
echo "$(tput setaf 2)$(tput bold)Setup Firewall... $(tput sgr 0)"
sudo ufw allow OpenSSH
sudo ufw --force enable

# timezone
echo "$(tput setaf 2)$(tput bold)Install timezone... $(tput sgr 0)"
sudo timedatectl set-timezone America/Vancouver
sudo apt-get -y install ntp

# basic modules
echo "$(tput setaf 2)$(tput bold)Install mics command... $(tput sgr 0)"
sudo apt-get -y install git tmux vim curl wget zip unzip htop dos2unix whois bc

# Enable sftp
echo "$(tput setaf 2)$(tput bold)Create sftp user group... $(tput sgr 0)"
sudo addgroup -q --system sftpUsers
sudo cp ./stubs/sftpUsers.conf /etc/ssh/sshd_config.d/sftpUsers.conf
sudo sed -i "s#/usr/lib/openssh/sftp-server#internal-sftp#g" /etc/ssh/sshd_config
sudo service ssh reload

# apache
echo "$(tput setaf 2)$(tput bold)Install Apache... $(tput sgr 0)"
sudo apt-get -y install apache2 build-essential apache2-dev apache2-utils

sudo wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo apt install -f
sudo rm -Rf libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb

sudo sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/server-name.conf
sudo a2enconf server-name
sudo a2dissite 000-default
sudo hostnamectl set-hostname localhost
sudo service apache2 restart

# php 7
echo "$(tput setaf 2)$(tput bold)Install PHP... $(tput sgr 0)"
sudo apt-get -y install php-fpm php-cli php-gd php-mysql
sudo apt-get -y install php-pgsql php-imap php-memcached php-mbstring php-xml
sudo apt-get -y install php-curl php-bcmath php-sqlite3 php-xdebug php-zip
ps aux | grep php

# connect apache to php
sudo a2enmod actions
sudo a2enmod proxy_fcgi setenvif
sudo a2enmod rewrite
sudo a2enconf php7.4-fpm
sudo cp /etc/apache2/mods-available/fastcgi.conf /etc/apache2/mods-available/fastcgi.conf.backup
sudo cp ./stubs/fastcgi.conf -rf /etc/apache2/mods-available/fastcgi.conf

# nginx
echo "$(tput setaf 2)$(tput bold)Install Nginx... $(tput sgr 0)"
sudo apt-get -y install nginx
sudo rm /etc/nginx/sites-enabled/default
sudo ufw allow 'Nginx Full'
sudo ufw --force enable

# reverse proxy setup
echo "$(tput setaf 2)$(tput bold)Install rpaf... $(tput sgr 0)"
sudo wget https://github.com/gnif/mod_rpaf/archive/stable.zip
sudo unzip stable.zip
cd mod_rpaf-stable
sudo make
sudo make install
cd ..
sudo cp ./stubs/rpaf.load -rf /etc/apache2/mods-available/rpaf.load
sudo cp ./stubs/rpaf.conf -rf /etc/apache2/mods-available/rpaf.conf
sudo a2enmod rpaf
sudo rm -Rf mod_rpaf-stable
sudo rm -Rf stable.zip
sudo service apache2 restart
sudo apt-get -y install libtool-bin
sudo libtool --finish /usr/lib/apache2/modules

# restart
echo "$(tput setaf 2)$(tput bold)Restarting services... $(tput sgr 0)"
sudo service nginx restart
sudo service php7.4-fpm restart
sudo service apache2 restart

# mysql
echo "$(tput setaf 2)$(tput bold)Install Mysql... $(tput sgr 0)"
sudo apt-get -y install mysql-server

echo "$(tput setaf 2)$(tput bold)Config Mysql... $(tput sgr 0)"
sudo mysql_secure_installation

MYSQL_CONF_FILE="$HOME/.my.cnf"
NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

sudo cp ./stubs/my.conf $MYSQL_CONF_FILE
sudo chown root: $MYSQL_CONF_FILE
sudo sed -i "s/{{PASSWORD}}/${NEW_UUID}/g" $MYSQL_CONF_FILE
sudo sed -i "s/{{USER}}/${USER}/g" $MYSQL_CONF_FILE

sudo mysql -e "CREATE USER IF NOT EXISTS '${USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${NEW_UUID}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${USER}'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

# compposer
echo "$(tput setaf 2)$(tput bold)Install Composer... $(tput sgr 0)"
sudo php -r "readfile('http://getcomposer.org/installer');" | sudo php -- --install-dir=/usr/bin/ --filename=composer
sudo cp ./stubs/cron-composer /etc/cron.d/composer
sudo mkdir ~/.composer/
sudo chown -R $USER: ~/.composer/

# node
echo "$(tput setaf 2)$(tput bold)Install Node... $(tput sgr 0)"
sudo apt-get -y install build-essential libssl-dev
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node # no sudo...

# laravel requirements
echo "$(tput setaf 2)$(tput bold)Install Laravel requirements... $(tput sgr 0)"
sudo apt-get -y install redis-server supervisor sqlite3 memcached
sudo systemctl enable redis-server

# Let's Encrypt (Using certbot-auto to always have latest version)
echo "$(tput setaf 2)$(tput bold)Install Let's Encrypt... $(tput sgr 0)"
sudo apt-get install -y certbot python3-certbot-nginx
sudo cp ./stubs/cron-certbot /etc/cron.d/certbot
# sudo certbot --install-only --non-interactive

# Diffie-Hellman Parameters
echo "$(tput setaf 2)$(tput bold)Generate dhparam.pem... $(tput sgr 0)"
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

# Laravel Installer
# echo "$(tput setaf 2)$(tput bold)Install Laravel installer... $(tput sgr 0)"
# composer global require "laravel/installer"
# echo 'export PATH="$PATH:$HOME/.composer/vendor/bin"' >> ~/.bashrc
# source ~/.bashrc

# Wp Installer
echo "$(tput setaf 2)$(tput bold)Install WP Cli... $(tput sgr 0)"
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

# Global Userful Bash
echo "$(tput setaf 2)$(tput bold)Add Aliases... $(tput sgr 0)"
echo "alias nah=\"git reset --hard; git clean -df;\"" | sudo tee /etc/profile.d/shared-alias.sh

# Root useful bash
echo "alias retest=\"sudo apachectl -t; sudo nginx -t; sudo php-fpm7.4 -t;\"" >> ~/.bash_aliases
echo "alias reload=\"sudo service apache2 reload;sudo service nginx reload;sudo service php7.4-fpm reload; echo 'Services Reloaded';\"" >> ~/.bash_aliases
echo "alias restart=\"sudo service apache2 restart; sudo service nginx restart; sudo service php7.4-fpm restart; echo 'Services Restarted';\"" >> ~/.bash_aliases
echo "alias stats=\"landscape-sysinfo\"" >> ~/.bash_aliases
source ~/.bash_aliases

# extra snippets
echo "$(tput setaf 2)$(tput bold)Copy Nginx snippets... $(tput sgr 0)"
sudo cp ./snippets/nginx-gzip.conf /etc/nginx/snippets/nginx-gzip.conf
sudo cp ./snippets/agent-filters.conf /etc/nginx/snippets/agent-filters.conf
sudo cp ./snippets/security.conf /etc/nginx/snippets/security.conf
sudo cp ./snippets/static.conf /etc/nginx/snippets/static.conf
sudo cp ./snippets/nginx-ssl.conf /etc/nginx/snippets/nginx-ssl.conf
sudo cp ./snippets/proxy-params.conf /etc/nginx/snippets/proxy-params.conf

# clean up
echo "$(tput setaf 2)$(tput bold)Cleaning up... $(tput sgr 0)"
sudo apt-get -y autoremove
sudo apt-get -y update
sudo apt-get -y upgrade
sudo service nginx restart
sudo service php7.4-fpm restart
sudo service apache2 restart

echo "$(tput setaf 2)$(tput bold)Boom DONE\! $(tput sgr 0)"
