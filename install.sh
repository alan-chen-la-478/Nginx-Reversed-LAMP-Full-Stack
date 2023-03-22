#!/bin/bash

. ./helpers.sh

# check ubuntu version and prump sudo
heading 'Prepare to start...'
lsb_release -a

heading 'Updating Ubuntu...'
apt-update ## >/dev/null 2>&1
apt-upgrade ## >/dev/null 2>&1
apt-dist-upgrade ## >/dev/null 2>&1
apt-install update-manager-core
sudo do-release-upgrade -f DistUpgradeViewNonInteractive

heading 'Update apt repositories...'
sudo apt-get install -y software-properties-common
sudo add-apt-repository -y ppa:ondrej/nginx ## >/dev/null 2>&1
sudo add-apt-repository -y ppa:ondrej/php ## >/dev/null 2>&1
sudo add-apt-repository -y ppa:ondrej/apache2 ## >/dev/null 2>&1
sudo add-apt-repository -y ppa:chris-lea/redis-server ## >/dev/null 2>&1

# do one more update run after repos added
apt-update ## >/dev/null 2>&1
apt-upgrade ## >/dev/null 2>&1
apt-dist-upgrade ## >/dev/null 2>&1

# hold the pending kernel update warnning
sudo apt-mark hold linux-image-generic ## >/dev/null 2>&1
# echo 'APT::ExtractTemplates::TempDir "/dev/null";' | sudo tee /etc/apt/apt.conf ## >/dev/null 2>&1
# echo 'APT::ExtractTemplates::TempDir "/dev/null";' | sudo tee /etc/apt/apt.conf ## >/dev/null 2>&1
# echo '$nrconf{kernelhints} = -1;' | sudo tee /etc/needrestart/conf.d/kernelhints.conf ## >/dev/null 2>&1
# echo '$nrconf{restart} = "a";' | sudo tee /etc/needrestart/conf.d/restart.conf ## >/dev/null 2>&1


heading "Install fail2ban and adding your current IP: $(who -m | awk '{print $NF}'), into sshd whitelist..."
apt-install fail2ban unattended-upgrades landscape-common net-tools
sudo systemctl enable fail2ban
sudo systemctl start fail2ban
sudo fail2ban-client set sshd addignoreip $(who -m | awk '{print $NF}') ## >/dev/null 2>&1

heading "Setup ufw Firewall..."
apt-install ufw
sudo ufw allow OpenSSH ## >/dev/null 2>&1
sudo ufw --force enable ## >/dev/null 2>&1
sudo ufw status verbose

heading "Setup timezone and auto sync..."
sudo timedatectl set-timezone America/Vancouver
apt-install ntp

heading "Install misc libraries..."
apt-install git tmux vim curl wget zip unzip htop dos2unix whois bc

heading "Create sftp user group..."
sudo addgroup --system sftpUsers ## >/dev/null 2>&1
sudo cp ./stubs/sftpUsers.conf /etc/ssh/sshd_config.d/sftpUsers.conf
sudo sed -i "s#/usr/lib/openssh/sftp-server#internal-sftp#g" /etc/ssh/sshd_config
sudo service ssh reload

heading "Install Apache..."
apt-install apache2 build-essential apache2-dev apache2-utils

sudo wget http://mirrors.kernel.org/ubuntu/pool/multiverse/liba/libapache-mod-fastcgi/libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb
sudo dpkg -i libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb ## >/dev/null 2>&1
sudo apt install -f ## >/dev/null 2>&1
sudo rm -Rf libapache2-mod-fastcgi_2.4.7~0910052141-1.2_amd64.deb

sudo sed -i "s/Listen 80/Listen 8080/" /etc/apache2/ports.conf
echo "ServerName localhost" | sudo tee /etc/apache2/conf-available/server-name.conf ## >/dev/null 2>&1
sudo a2enconf server-name ## >/dev/null 2>&1
sudo a2dissite 000-default ## >/dev/null 2>&1
sudo hostnamectl set-hostname localhost
sudo service apache2 restart

heading "Install PHP 7.4..."
install-php 7.4

heading "Install PHP 8.0..."
install-php 8.0

heading "Install PHP 8.1..."
install-php 8.1

heading "Install PHP 8.2..."
install-php 8.2

sudo a2enmod actions
sudo a2enmod proxy_fcgi setenvif
sudo a2enmod rewrite
sudo a2enconf php7.4-fpm php8.0-fpm php8.1-fpm php8.2-fpm

# ??
# sudo cp /etc/apache2/mods-available/fastcgi.conf /etc/apache2/mods-available/fastcgi.conf.backup
# sudo cp ./stubs/fastcgi.conf -rf /etc/apache2/mods-available/fastcgi.conf

update-alternatives --set php $(update-alternatives --list php | tail -n 1) ## >/dev/null 2>&1
php -v

heading "Install Nginx..."
apt-install nginx
sudo rm /etc/nginx/sites-enabled/default
sudo ufw allow 'Nginx Full' ## >/dev/null 2>&1
sudo ufw --force enable ## >/dev/null 2>&1

heading "Install rpaf..."
sudo wget https://github.com/gnif/mod_rpaf/archive/stable.zip
sudo unzip -o stable.zip
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
apt-install libtool-bin
sudo libtool --finish /usr/lib/apache2/modules

heading "Restarting services..."
sudo service nginx restart
sudo service php7.4-fpm restart
sudo service php8.0-fpm restart
sudo service php8.1-fpm restart
sudo service php8.2-fpm restart
sudo service apache2 restart

heading "Install MySQL..."
echo "$(tput setaf 2)$(tput bold)Install Mysql... $(tput sgr 0)"
apt-install mysql-server

MYSQL_ROOT_CONF_FILE="/root/.my.cnf"
DB_ROOT_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
sudo cp ./stubs/my.conf $MYSQL_ROOT_CONF_FILE
sudo chown root: $MYSQL_ROOT_CONF_FILE
sudo sed -i "s/{{PASSWORD}}/${DB_ROOT_PASSWORD}/g" $MYSQL_ROOT_CONF_FILE
sudo sed -i "s/{{USER}}/${USER}/g" $MYSQL_ROOT_CONF_FILE

MYSQL_CONF_FILE="$HOME/.my.cnf"
DB_PASSWORD=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)
sudo cp ./stubs/my.conf $MYSQL_CONF_FILE
sudo chown root: $MYSQL_CONF_FILE
sudo sed -i "s/{{PASSWORD}}/${DB_PASSWORD}/g" $MYSQL_CONF_FILE
sudo sed -i "s/{{USER}}/${USER}/g" $MYSQL_CONF_FILE

sudo mysql -e "ALTER USER root@localhost IDENTIFIED BY '${DB_ROOT_PASSWORD}'"
sudo mysql -e "DROP USER ''@'localhost'"
sudo mysql -e "DROP USER ''@'$(hostname)'"
sudo mysql -e "DROP DATABASE IF EXISTS test"
sudo mysql -e "FLUSH PRIVILEGES"

sudo mysql -e "CREATE USER IF NOT EXISTS '${USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${DB_PASSWORD}';"
sudo mysql -e "GRANT ALL PRIVILEGES ON *.* TO '${USER}'@'localhost' WITH GRANT OPTION;"
sudo mysql -e "FLUSH PRIVILEGES;"

heading "Install Node via NVM..."
apt-install build-essential libssl-dev
sudo curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.35.3/install.sh | bash
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
nvm install node # no sudo...

heading "Install cacheing related..."
apt-install redis-server memcached
sudo systemctl enable redis-server

heading "Install LetsEncrypt..."
sudo apt-get install -y certbot python3-certbot-nginx
sudo cp ./stubs/cron-certbot /etc/cron.d/certbot

heading "Generate dhparam.pem..."
sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

heading "Install WP Cli..."
sudo curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
sudo chmod +x wp-cli.phar
sudo mv wp-cli.phar /usr/local/bin/wp

heading "Setup server alias..."
echo "alias retest=\"sudo apachectl -t; sudo nginx -t; sudo php-fpm7.4 -t; sudo php-fpm8.0 -t; sudo php-fpm8.1 -t; sudo php-fpm8.2 -t;\"" | sudo tee -a /etc/profile.d/shared-alias.sh
echo "alias reload=\"sudo service apache2 reload;sudo service nginx reload;sudo service php7.4-fpm reload;sudo service php8.0-fpm reload;sudo service php8.1-fpm reload;sudo service php8.2-fpm reload;\"" | sudo tee -a /etc/profile.d/shared-alias.sh
echo "alias restart=\"sudo service apache2 restart; sudo service nginx restart; sudo service php7.4-fpm restart;sudo service php8.0-fpm restart;sudo service php8.1-fpm restart;sudo service php8.2-fpm restart;\"" | sudo tee -a /etc/profile.d/shared-alias.sh
echo "alias stats=\"landscape-sysinfo\"" | sudo tee -a /etc/profile.d/shared-alias.sh
source /etc/profile.d/shared-alias.sh

heading "Copy Nginx snippets..."
sudo cp ./snippets/nginx-gzip.conf /etc/nginx/snippets/nginx-gzip.conf
sudo cp ./snippets/agent-filters.conf /etc/nginx/snippets/agent-filters.conf
sudo cp ./snippets/security.conf /etc/nginx/snippets/security.conf
sudo cp ./snippets/static.conf /etc/nginx/snippets/static.conf
sudo cp ./snippets/nginx-ssl.conf /etc/nginx/snippets/nginx-ssl.conf
sudo cp ./snippets/proxy-params.conf /etc/nginx/snippets/proxy-params.conf

heading "Cleaning up..."
sudo apt-get -y autoremove
apt-update
apt-upgrade
apt-dist-upgrade
retest
restart

# release the pending kernel update warnning
# sudo apt-mark unhold linux-image-generic ## >/dev/null 2>&1
# sudo rm -Rf /etc/apt/apt.conf
# sudo rm -Rf /etc/needrestart/conf.d/kernelhints.conf
# sudo rm -Rf /etc/needrestart/conf.d/restart.conf

sudo netstat -tlpn
