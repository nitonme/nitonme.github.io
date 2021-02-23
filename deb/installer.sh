#!/bin/bash

export ITALIC='\e[3m'
export RESET_ALL='\e[0m'
export PURPLE='\e[0;35m'
export LIGHT_GREEN='\e[1;32m'


##  Must be run as root
if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root.";
    exit 1;
fi

install_apache() {

    ##  Installing Apache2
    echo -e "\n [${LIGHT_GREEN}+${RESET_ALL}] Installing Apache HTTP Server...\n";
    sudo apt-get install -y apache2 && echo -e "[ ${LIGHT_GREEN}OK${RESET_ALL} ]\n";
    sleep 2

    ##  Stopping the Apache2 service
    sudo service apache2 stop

    ##  Disabling the default configuration.
    echo "> Default configuration disabled." && sudo a2dissite 000-default.conf >/dev/null 2>&1
    sleep 2

    ##  Deleting the default configuration.
    echo "> Default configuration deleted." && sudo rm /etc/apache2/sites-available/000-default.conf
    sleep 2

    echo -ne "Domain Name -> (eg. domain.com): ${LIGHT_GREEN}";
    read domainName

    DOMAIN_FOLDER=${domainName//./_}

    echo -e "${RESET_ALL}> Domain ${LIGHT_GREEN}${domainName}${RESET_ALL} is set.";
    sleep 3

    echo "> New configuration file created." && sudo touch /etc/apache2/sites-available/${DOMAIN_FOLDER}.conf
    sleep 2

    sudo mkdir -p /var/www/${DOMAIN_FOLDER} && echo -e "> Folder ${PURPLE}'/var/www/${DOMAIN_FOLDER}'${RESET_ALL} was created.";
    sleep 2

sudo echo "
Listen 80
Listen 443

<VirtualHost *:80>

        ServerAdmin webmaster@localhost
        DocumentRoot /var/www/${DOMAIN_FOLDER}
        ServerName ${domainName}
        ServerAlias www.${domainName}

        ErrorLog \${APACHE_LOG_DIR}/error.log
        CustomLog \${APACHE_LOG_DIR}/access.log combined

</VirtualHost>

" > /etc/apache2/sites-available/${DOMAIN_FOLDER}.conf && echo "> Virtual Host has been written.";

    sleep 2
    sudo a2ensite ${DOMAIN_FOLDER}.conf >/dev/null 2>&1 && echo "> The new configuration enabled.";
    sleep 1
    sudo service apache2 start
    echo -ne "> Reloading service Apache2" && sudo systemctl reload apache2 >/dev/null 2>&1 && echo -e " [ ${LIGHT_GREEN}OK${RESET_ALL} ]";

}
install_php() {

    echo -e "\n> Adding latest PHP thrid-party PPA." && wget -q https://packages.sury.org/php/apt.gpg -O- | sudo apt-key add - >/dev/null 2>&1
    sudo echo "deb https://packages.sury.org/php/ stretch main" | tee /etc/apt/sources.list.d/php.list >/dev/null 2>&1
    sleep 2
    echo -e "> System update." && sudo apt-get update -y >/dev/null 2>&1

    sleep 1
    echo -e "\n[${LIGHT_GREEN}+${RESET_ALL}] Installing PHP ...\n";

    sleep 2
    sudo apt-get install -y php php-mysql libapache2-mod-php && echo -e "[ ${LIGHT_GREEN}OK${RESET_ALL} ]";

    PHP_VERSION=$(php -v | grep ^PHP | cut -d' ' -f2)

    sleep 1
    echo -e "\n> PHP ${PHP_VERSION} installed. \n";
    sleep 2
}


if [[ $1 == "--install" ]]; then
  /usr/bin/clear
  echo
  curl https://niton.me/deb/serverbuild.txt
  echo -e "This script will be installing:\n   [${LIGHT_GREEN}+${RESET_ALL}] Apache HTTP Server\n   [${LIGHT_GREEN}+${RESET_ALL}] PHP: Hypertext Preprocessor";
  echo -e "\nThe configurations will be automated too.";

  read -p "Start auto install/config? (y/n) " YesNo

  if [[ $YesNo =~ ^[Yy]$ ]]; then

        echo -e "\n> System updating." && sudo apt-get update -y >/dev/null 2>&1
        echo -e "> System upgrading." && sudo apt-get upgrade -y >/dev/null 2>&1

        install_apache;
        install_php;

        echo -e "\nAll done.";
  else
        echo "Well, OK bye.";
        exit 1;
  fi
fi
