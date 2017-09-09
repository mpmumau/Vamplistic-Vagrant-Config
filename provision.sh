#!/bin/bash

#
# File: provision.sh
#
# This shell script provisions script the Vamplistic Vagrant VM.
#
# Created: Sept. 1, 2017
# Author: Matt Mumau <mpmumau@gmail.com>
#

# The total amount of steps in this process; used for console output.
TOTAL_STEPS=10
# The current step; used for console output.
CURRENT_STEP=1

# -----------------------------------------------------------------------------
# Package versions
# -----------------------------------------------------------------------------

V_NETSELECT_APT="0.3.ds1-26"
V_VIM="2:7.4.488-7+deb8u3"
V_CURL="7.38.0-4+deb8u5"
V_TMUX="1.9-6"
V_RUBY="1:2.1.5+deb8u2"
V_PYTHON_SOFTWARE_PROPERTIES="0.92.25debian1"
V_SOFTWARE_PROPERTIES_COMMON="0.92.25debian1"
V_GIT="1:2.1.4-2.1+deb8u4"
V_APACHE2="2.4.10-10+deb8u10"
V_PHP5="5.6.30+dfsg-0+deb8u1"
V_PHP5_IMAGICK="3.2.0~rc1-1"
V_PHP7="7.0.22-1~dotdeb+8.1"
V_PHP7_IMAGICK="3.4.3-1~dotdeb+8.1"
V_MARIA_DB="10.0.32-0+deb8u1"
V_POSTFIX="2.11.3-1+deb8u2"
V_LIBSQLITE3_DEV="3.8.7.1-1+deb8u2"

# Print formatted output to the console.
function print_status() {
    echo -e "\e[46m[Vamplistic]\e[0m \e[100m[$CURRENT_STEP/$TOTAL_STEPS]\e[0m \e[35m$1...\e[0m"
    let "CURRENT_STEP += 1"
}

# Configure the provisioner to operate without a command prompt.
export DEBIAN_FRONTEND=noninteractive

# Configure environment variables
# TODO: Check for existing environment variables and replace them instead of
# adding new entries if they exist.
chmod +x env.sh
./env.sh

# Update Aptitude repositories.
print_status "Optimizing Apt and updating package repositories"
# TODO: Check if the package has been installed already.
apt-get -y -q install netselect-apt=$V_NETSELECT_APT
netselect-apt
apt-get -y -q update

# System libraries and config
print_status "Installing system libraries"
# TODO: Check if these packages have already been installed
apt-get -y -q install \
    software-properties-common=$V_SOFTWARE_PROPERTIES_COMMON \
    python-software-properties=$V_PYTHON_SOFTWARE_PROPERTIES

# TODO: Check if these pckages have already been installed
apt-get -y -q install \
    vim=$V_VIM \
    curl=$V_CURL \
    tmux=$V_TMUX \
    libsqlite3-dev=$V_LIBSQLITE3_DEV \
    ruby-full=$V_RUBY

cp config/bash/bash.bashrc /etc/bash.bashrc

> /home/root/.bashrc
cat config/bash/root.bashrc >> /home/root/.bashrc

> /home/vagrant/.bashrc
cat config/bash/.bashrc >> /home/vagrant/.bashrc

# Install Git
print_status "Installing Git"
# TODO: Check if the package has been already installed
apt-get -y -q install git=$V_GIT

# Install Apache
print_status "Installing Apache"
# TODO: Check if certificate files have already been generated
cd /vagrant/config/apache2
openssl genrsa -des3 -passout pass:x -out $VAMP_APP_DOMAIN.pass.key 2048
openssl rsa -passin pass:x -in $VAMP_APP_DOMAIN.pass.key -out $VAMP_APP_DOMAIN.key
rm $VAMP_APP_DOMAIN.pass.key
# openssl req -new -key vamplistic.dev.key -out vamplistic.dev.csr
openssl req -nodes -newkey rsa:2048 -keyout $VAMP_APP_DOMAIN.key -out $VAMP_APP_DOMAIN.csr -subj "/C=US/ST=New York/L=New York/O="$VAMP_APP_NAME"/OU=Dev/CN="$VAMP_APP_DOMAIN
openssl x509 -req -days 365 -in $VAMP_APP_DOMAIN.csr -signkey $VAMP_APP_DOMAIN.key -out $VAMP_APP_DOMAIN.crt

# TODO: Check if the packages have already been installed
apt-get -y -q install apache2=$V_APACHE2 apache2-doc=$V_APACHE2 apache2-utils=$V_APACHE2

cp /vagrant/config/apache2/000-default.conf /etc/apache2/sites-available/000-default.conf
ln -s /etc/apache2/sites-available/000-default.conf /etc/apache2/sites-enabled/000-default.conf

ln -s /vagrant/shared/project /var/www/default
chown www-data:www-data /var/www/default
rm -R /var/www/html

a2enmod ssl
a2enmod rewrite

service apache2 restart

# Install PHP
print_status "Installing PHP"
if [ "$PHP5_VS_7" = true ]; then
    # TODO: Check if the packages have already been installed
    apt-get -y -q install \
        php5=$V_PHP5 \
        libapache2-mod-php5=$V_PHP5 \
        php5-mcrypt=$V_PHP5 \
        php5-curl=$V_PHP5 \
        php5-imagick=$V_PHP5_IMAGICK

    # TODO: Set the correct file location for the PHP5 .ini file.
    #cp /vagrant/config/php/5.0/php.ini /etc/php5/php.ini
else
    # TODO: Check if the packages have already been installed
    cd /tmp
    wget https://www.dotdeb.org/dotdeb.gpg
    apt-key add dotdeb.gpg
    
    add-apt-repository 'deb http://packages.dotdeb.org jessie all'
    apt-get -y -q update

    apt-get -y -q install php7.0=$V_PHP7 \
        php7.0-mcrypt=$V_PHP7 \
        php7.0-curl=$V_PHP7 \
        php7.0-imagick=$V_PHP7_IMAGICK

    cp /vagrant/config/php/7.0/php.ini /etc/php/7.0/apache2/php.ini
fi

# Install MariaDB

# Set default inputs for MariaDB installation prompts.
print_status "Configuring MariaDB installation answers"

# TODO: Check if the package has already been installed.
debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password password $VAMP_DB_PASS"
debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password_again password $VAMP_DB_PASS"

# Add apt-keys for the MariaDB repository.
print_status "Adding MariaDB installation keys and repository location"
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb https://mirrors.evowise.com/mariadb/repo/10.1/debian sid main'
apt-get -y -q update

# Install the MariaDB packages
print_status "Installing MariaDB"
apt-get -y -q --force-yes install mariadb-server=$V_MARIA_DB mariadb-client=$V_MARIA_DB

# Install Postfix or MailCatcher
if [ VAMP_IS_DEV=false ]; then
    print_status "Installing Postfix"
    apt-get -y -q install postfix=$V_POSTFIX
else
    print_status "Installing MailCatcher"
    gem install mailcatcher
fi



