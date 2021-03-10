#!/bin/bash

export ITALIC='\e[3m'
export RESET_ALL='\e[0m'
export PURPLE='\e[0;35m'
export RED='\e[1;31m'
export LIGHT_GREEN='\e[1;32m'
export LIGHT_BLUE='\e[1;34m'

export VERSION='1.6.0'


##  Must be run with sudo.
if [[ $EUID -ne 0 ]]; then
    echo "Run this script with sudo.";
    exit 1;
fi

install_apache() {

    ##  Installing Apache2
    echo -ne "\n  [${LIGHT_GREEN}+${RESET_ALL}] Installing Apache HTTP Server... ";
    sudo apt-get install -y apache2 >/dev/null 2>&1 && echo -e "[ ${LIGHT_GREEN}OK${RESET_ALL} ]\n";
    sleep 3

    ##  Disabling the default configuration.
    sudo a2dissite 000-default.conf >/dev/null 2>&1 && echo "  Default configuration disabled."
    sleep 2

    ##  Deleting the default configuration.
    sudo rm /etc/apache2/sites-available/000-default.conf && echo "  Default configuration deleted."
    sleep 2

    echo -ne "  Domain Name -> (eg. domain.com): ${LIGHT_GREEN}";
    read domainName

    DOMAIN_FOLDER=${domainName//./_}

    echo -e "${RESET_ALL}  Domain ${LIGHT_GREEN}${domainName}${RESET_ALL} is set.";
    sleep 3

    sudo touch /etc/apache2/sites-available/${DOMAIN_FOLDER}.conf && echo "  New configuration file created."
    sleep 2

    ##  Removing the standard html directory
    sudo rm -rf /var/www/html

    sudo mkdir -p /var/www/${DOMAIN_FOLDER} && echo -e "  Folder ${ITALIC}'/var/www/${DOMAIN_FOLDER}'${RESET_ALL} was created.";
    sleep 2

    ##  Downloading the default webpage to the newly created folder.
    sudo curl -s -o /var/www/${DOMAIN_FOLDER}/index.php https://niton.me/deb/workphp


sudo echo -e "

<VirtualHost *:80>

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/${DOMAIN_FOLDER}
        ServerName ${domainName}
        ServerAlias www.${domainName}

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

" >> /etc/apache2/sites-available/${DOMAIN_FOLDER}.conf && echo -ne "  Config has been written";
    sleep 1
    sudo a2ensite ${DOMAIN_FOLDER}.conf >/dev/null 2>&1 && echo -e " and enabled.";

    echo -ne "  Reloading service Apache2" && sudo systemctl reload apache2 >/dev/null 2>&1 && echo -e " [ ${LIGHT_GREEN}OK${RESET_ALL} ]";



}
install_php() {

    echo -e "\n  Adding latest PHP third-party PPA." && wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - >/dev/null 2>&1
    sudo echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list >/dev/null 2>&1
    sleep 2
    echo -e "  System updating.." && sudo apt-get update -y >/dev/null 2>&1

    sleep 1
    echo -ne "\n  [${LIGHT_GREEN}+${RESET_ALL}] Installing PHP ... ";

    sleep 2
    sudo apt-get install -y php php-mysql libapache2-mod-php >/dev/null 2>&1 && echo -e "  [ ${LIGHT_GREEN}OK${RESET_ALL} ]";

    PHP_VERSION=$(php -v | grep ^PHP | cut -d' ' -f2)

    sleep 1
    echo -e "\n  PHP ${PHP_VERSION} installed.";
    sleep 2


}
install_certbot() {

    echo -ne "\n  [${LIGHT_GREEN}+${RESET_ALL}] Installing snapd... ";
    sudo apt install -y snapd >/dev/null 2>&1 && echo -e "  [ ${LIGHT_GREEN}OK${RESET_ALL} ]";
    sleep 2
    ## Ensure version of snapd is up to date.
    sudo snap install core >/dev/null 2>&1 && sudo snap refresh core >/dev/null 2>&1

    echo -ne "  [${LIGHT_GREEN}+${RESET_ALL}] Installing Certbot... ";
    sudo snap install --classic certbot >/dev/null 2>&1 && echo -e "[ ${LIGHT_GREEN}OK${RESET_ALL} ]\n";

    sudo ln -s /snap/bin/certbot /usr/bin/certbot

    ##  Give domain tls/ssl cerificate.
    sudo certbot --apache -d www.${domainName} -d ${domainName}
}


if [[ $1 == "--install" ]]; then
  /usr/bin/clear
  echo
  curl https://niton.me/deb/serverbuild.txt
  echo -e "${PURPLE}Version ${VERSION}${RESET_ALL}\nOnly run this on a freshly installed linux box.\nServer.Build does this:\n   [${LIGHT_GREEN}+${RESET_ALL}] Installing Apache2\n   [${LIGHT_GREEN}+${RESET_ALL}] Installing lastest PHP";
  echo -e "   [${LIGHT_GREEN}+${RESET_ALL}] TLS/SSL Cerificate (HTTPS)\n   [${LIGHT_GREEN}+${RESET_ALL}] HTTP/2";
  echo -e "\n  The configurations will be automated too.";

  read -p "  Start auto install/config? (y/n) " YesNo

  if [[ $YesNo =~ ^[Yy]$ ]]; then

        echo -ne "\n  System update. " && sudo apt-get update -y >/dev/null 2>&1 && echo -e " [ ${LIGHT_GREEN}DONE${RESET_ALL} ]";
        echo -ne "  System upgrade. " && sudo apt-get upgrade -y >/dev/null 2>&1 && echo -e "[ ${LIGHT_GREEN}DONE${RESET_ALL} ]";

        install_apache;
        install_php;
        install_certbot;

        echo "  Test it out -> https://${domainName}/"
        echo -e "\n  All done.";
  else
        echo "  Well OK, bye.";
        exit 1;
  fi
fi
