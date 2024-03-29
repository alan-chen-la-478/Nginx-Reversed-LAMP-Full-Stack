#!/bin/bash

if [ -z "$(getent passwd $USER)" ]; then
    echo "$(tput setaf 2)$(tput bold)Creating New User... $(tput sgr 0)"
    sudo mkdir -p $SERVED_PATH
    sudo mkdir -p "${VHOST_PATH}logs"

    RANDOM_PASSWORD=$(openssl rand -base64 12)
    PASSWORD=$(prompt_input "Enter a password (leave empty to generate random one): " "-s");
    if [ -z "$PASSWORD" ]; then
        PASSWORD=$RANDOM_PASSWORD
    fi

    echo "";
    sudo adduser --gecos "" --disabled-password $USER
    echo "$USER:$PASSWORD" | sudo chpasswd
    sudo usermod -d $HOME_DIR $USER

    if [ "$RANDOM_PASSWORD" = "$PASSWORD" ]; then
        USER_PASSWD_FILE=$HOME_DIR.sshpwd
        echo $PASSWORD | sudo tee $USER_PASSWD_FILE ## >/dev/null 2>&1
        echo "Password Generated: $(tput bold)${USER_PASSWD_FILE}$(tput sgr 0)";
    fi

    if [ "$SSH" = false ] ; then
        sudo usermod -s /bin/false $USER # disable ssh
        # sudo usermod -s /bin/bash $USER
    fi

    if [ "$SFTP" = true ] ; then
        sudo usermod -a -G sftpUsers $USER #enable SFTP
    fi

    echo "User: '$USER' created."

    MYSQL_CONF_FILE="${HOME_DIR}.my.cnf"
    NEW_UUID=$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)

    sudo cp -R ./stubs/my.conf $MYSQL_CONF_FILE
    sudo chown root: $MYSQL_CONF_FILE
    sudo sed -i "s/{{PASSWORD}}/${NEW_UUID}/g" $MYSQL_CONF_FILE
    sudo sed -i "s/{{USER}}/${USER}/g" $MYSQL_CONF_FILE

    sudo mysql -e "CREATE USER IF NOT EXISTS '${USER}'@'localhost' IDENTIFIED WITH mysql_native_password BY '${NEW_UUID}';"
    sudo mysql -e "GRANT ALL PRIVILEGES ON \`${USER}_%\`.* TO '${USER}'@'localhost';"

    echo "MySQL User: '$USER' | '$NEW_UUID' created. | $MYSQL_CONF_FILE"
else
    echo "User: '$USER' already exists."
fi
