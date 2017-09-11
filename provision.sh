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
# The subdirectory to use as the root share directory with Vagrant.
VGRNT_DIR="/vagrant"
# The configuration directory.
CONFIG_DIR=$VGRNT_DIR/config
# The data directory.
LOG_DIR=$VGRNT_DIR/logs

# -----------------------------------------------------------------------------
# Package versions
# -----------------------------------------------------------------------------

V_NETSELECT_APT="0.3.ds1-26"
V_APT_TRANSPORT_HTTPS="1.0.9.8.4"
V_VIM="2:7.4.488-7+deb8u3"
V_CURL="7.38.0-4+deb8u5"
V_TMUX="1.9-6"
V_RUBY="1:2.1.5+deb8u2"
V_BUILD_ESSENTIAL="11.7"
V_SOFTWARE_PROPERTIES_COMMON="0.92.25debian1"
V_PYTHON_SOFTWARE_PROPERTIES="0.92.25debian1"
V_GIT="1:2.1.4-2.1+deb8u4"
V_APACHE2="2.4.10-10+deb8u10"
V_PHP5="5.6.30+dfsg-0+deb8u1"
V_PHP5_IMAGICK="3.2.0~rc1-1"
V_PHP7="7.0.23-1~dotdeb+8.1"
V_PHP7_IMAGICK="3.4.3-1~dotdeb+8.1"
V_MARIA_DB="10.0.32-0+deb8u1"
V_POSTFIX="2.11.3-1+deb8u2"
V_LIBSQLITE3_DEV="3.8.7.1-1+deb8u2"
V_MAILCATCHER="0.6.5"
V_PHP5_XDEBUG="2.2.5-1 0"
V_PHP7_XDEBUG="1:2.5.1-1~dotdeb+8.1"

# Print formatted output to the console.
function print_status() 
{
    echo -e "\e[46m[Vamplistic]\e[0m \e[100m[$CURRENT_STEP/$TOTAL_STEPS]\e[0m \e[35m$1...\e[0m"
    let "CURRENT_STEP += 1"
}

# Check if a given package has already been installed. Returns "true" or "false".
function pkg_exists()
{
    PKG_GIVEN=$1
    PKG_V_GIVEN=$2

    PKG_NAME=$(dpkg -l | awk -v pkg_given="$PKG_GIVEN" '{ if ($2 == pkg_given) print $2; }')
    PKG_V=$(dpkg -l | awk -v pkg_given="$PKG_GIVEN" '{ if ($2 == pkg_given) print $3; }')

    if [ "$PKG_NAME" == "$PKG_GIVEN" ]; then
        if [ "$PKG_V" == "$PKG_V_GIVEN" ]; then
            echo "true"
            return
        fi
    fi

    echo "false"
}

# Add a given Aptitude package name to the list of installed packages.
function add_to_pkg_list()
{
    PKG_GIVEN=$1
    PKG_FILE=$LOG_DIR/installed_pkgs.log

    touch $PKG_FILE

    PKG_IN_LIST=`grep "$PKG_GIVEN" "$PKG_FILE"`
    if [ -z "$PKG_IN_LIST" ]; then
        echo $PKG_GIVEN >> $PKG_FILE
    fi
}

# Add a given package name to the list of install Ruby gems.
function add_to_gem_list()
{
    PKG_GIVEN=$1
    GEMS_FILE=$LOG_DIR/installed_ruby_gems.log

    touch $GEMS_FILE

    PKG_IN_LIST=`grep "$PKG_GIVEN" "$GEMS_FILE"`
    if [ -z "$PKG_IN_LIST" ]; then
        echo $PKG_GIVEN >> $GEMS_FILE
    fi
}

# Install an Aptitude package.
function install_pkg()
{
    PKG_GIVEN=$1
    PKG_V_GIVEN=$2
    PKG_ARGS=$3

    add_to_pkg_list $PKG_GIVEN

    PKG_EXISTS=$(pkg_exists $PKG_GIVEN $PKG_V_GIVEN)

    if [ "$PKG_EXISTS" == "true" ]; then
        echo -e "\e[37m$PKG_GIVEN $PKG_V_GIVEN \e[90malready installed. Skipping installation.\e[39m"
        return
    fi

    echo -e "\e[35mInstalling package: \e[94m$PKG_GIVEN $PKG_V_GIVEN\e[39m"
    apt-get install -y -q $PKG_ARGS $PKG_GIVEN=$PKG_V_GIVEN
}

# Install a Ruby gem and log it.
function install_ruby_gem()
{
    PKG_GIVEN=$1
    PKG_VERSION=$2

    add_to_gem_list $PKG_GIVEN

    gem install $PKG_GIVEN -v $PKG_VERSION
}

# Replace a given token with a given file in the given file.
function replace_token()
{
    TOKEN=$1
    REPLACE=$2
    FILE=$3

    echo "[replace_token] $TOKEN | $REPLACE | $FILE"

    sed -i "s/{{$TOKEN}}/$REPLACE/g" $FILE
}

# Remove the package log if it exists
if [ -e $LOG_DIR/installed_pkgs.log ]; then
    rm $LOG_DIR/installed_pkgs.log
fi

# Configure the provisioner to operate without a command prompt.
export DEBIAN_FRONTEND=noninteractive

# Configure environment variables
source /vagrant/env.sh
echo "VAMP_APP_DOMAIN: "$VAMP_APP_DOMAIN
echo "VAMP_DB_USER: "$VAMP_DB_USER
echo "VAMP_DB_PASS: "$VAMP_DB_PASS
echo "VAMP_DB_NAME: "$VAMP_DB_NAME
echo "VAMP_APP_DEV_DOMAIN: "$VAMP_APP_DEV_DOMAIN

# Update Aptitude repositories.
print_status "Optimizing Apt and updating package repositories"
install_pkg netselect-apt $V_NETSELECT_APT
netselect-apt > /dev/null 2>&1
apt-get -y -q update

# System libraries and config
print_status "Installing system libraries"
install_pkg build-essential $V_BUILD_ESSENTIAL
install_pkg software-properties-common $V_SOFTWARE_PROPERTIES_COMMON
install_pkg python-software-properties $V_PYTHON_SOFTWARE_PROPERTIES

install_pkg apt-transport-https $V_APT_TRANSPORT_HTTPS
install_pkg vim $V_VIM
install_pkg curl $V_CURL
install_pkg tmux $V_TMUX
install_pkg libsqlite3-dev:amd64 $V_LIBSQLITE3_DEV
install_pkg ruby-full $V_RUBY

cp $CONFIG_DIR/bash/bash.bashrc /etc/bash.bashrc

> /home/root/.bashrc
cat $CONFIG_DIR/bash/root.bashrc >> /home/root/.bashrc

> /home/vagrant/.bashrc
cat $CONFIG_DIR/bash/.bashrc >> /home/vagrant/.bashrc

# Install Git
print_status "Installing Git"
install_pkg git $V_GIT

# Install Apache
print_status "Installing Apache"
install_pkg apache2 $V_APACHE2
install_pkg apache2-doc $V_APACHE2
install_pkg apache2-utils $V_APACHE2

a2enmod ssl
a2enmod rewrite

# Configure App
VAMP_WORKING_DOMAIN=""
if [ "$VAMP_IS_DEV" == "true" ]; then
    VAMP_WORKING_DOMAIN=$VAMP_APP_DEV_DOMAIN
else
    VAMP_WORKING_DOMAIN=$VAMP_APP_DOMAIN
fi

VAMP_CERT_DIR="/etc/apache2/ssl"
if [ ! -d "$VAMP_CERT_DIR" ]; then
    mkdir $VAMP_CERT_DIR
fi

# Configure Vamplistic App virtual host
if [ "$VAMP_IS_DEV" == "true" ]; then
    VDN="vamplistic.$VAMP_WORKING_DOMAIN"
    VAMPLISTIC_DEV_APP_SL_DIR="/var/www/$VDN"
    VAMPLISTIC_DEV_APP_SL_DIR_ESC="\/var\/www\/$VDN"
    ln -s "/vagrant/app" "$VAMPLISTIC_DEV_APP_SL_DIR"
    chown www-data:www-data "$VAMPLISTIC_DEV_APP_SL_DIR"
    
    cd "$VAMP_CERT_DIR"
    openssl genrsa -des3 -passout pass:x -out "$VDN.pass.key" 2048 
    openssl rsa -passin pass:x -in "$VDN.pass.key" -out "$VDN.key"
    rm "$VDN.pass.key"

    openssl req -nodes -newkey rsa:2048 -keyout "$VDN.key" -out "$VDN.csr" -subj "/C=US/ST=New York/L=New York/O=$VAMP_APP_NAME/OU=Dev/CN=$VDN"
    openssl x509 -req -days 365 -in "$VDN.csr" -signkey "$VDN.key" -out "$VDN.crt"

    VAMP_CONF_FILENAME="$VDN.conf"
    VAMP_APACHE_CONF="/etc/apache2/sites-available/$VAMP_CONF_FILENAME"

    cp "$CONFIG_DIR/apache2/000-default.conf" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_DOMAIN_NAME' "$VDN" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_DOCUMENT_ROOT' "\/var\/www\/$VDN" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_DB_USER' "$VAMP_DB_USER" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_DB_PASS' "$VAMP_DB_PASS" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_DB_NAME' "$VAMP_DB_NAME" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_SSL_CERT' "\/etc\/apache2\/ssl\/$VDN.crt" "$VAMP_APACHE_CONF"
    replace_token 'VAMP_SSL_KEY' "\/etc\/apache2\/ssl\/$VDN.key" "$VAMP_APACHE_CONF"
    ln -s "$VAMP_APACHE_CONF" "/etc/apache2/sites-enabled/$VAMP_CONF_FILENAME"
fi

# Configure project host
cd $VAMP_CERT_DIR
openssl genrsa -des3 -passout pass:x -out "$VAMP_WORKING_DOMAIN.pass.key" 2048 
openssl rsa -passin pass:x -in "$VAMP_WORKING_DOMAIN.pass.key" -out "$VAMP_WORKING_DOMAIN.key"
rm "$VAMP_WORKING_DOMAIN.pass.key"

openssl req -nodes -newkey rsa:2048 -keyout "$VAMP_WORKING_DOMAIN.key" -out "$VAMP_WORKING_DOMAIN.csr" -subj "/C=US/ST=New York/L=New York/O=$VAMP_APP_NAME/OU=Dev/CN=$VAMP_WORKING_DOMAIN"
openssl x509 -req -days 365 -in "$VAMP_WORKING_DOMAIN.csr" -signkey "$VAMP_WORKING_DOMAIN.key" -out "$VAMP_WORKING_DOMAIN.crt"

VAMPLISTIC_PROJ_SL_DIR="/var/www/$VAMP_WORKING_DOMAIN"
ln -s "/vagrant/shared/project" "$VAMPLISTIC_PROJ_SL_DIR"

VAMP_APACHE_PROJ_CONF="/etc/apache2/sites-available/$VAMP_WORKING_DOMAIN.conf"
cp "$CONFIG_DIR/apache2/000-default.conf" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_DOMAIN_NAME' "$VAMP_WORKING_DOMAIN" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_DOCUMENT_ROOT' "\/var\/www\/$VAMP_WORKING_DOMAIN" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_DB_USER' "$VAMP_DB_USER" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_DB_PASS' "$VAMP_DB_PASS" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_DB_NAME' "$VAMP_DB_NAME" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_SSL_CERT' "\/etc\/apache2\/ssl\/$VAMP_WORKING_DOMAIN.crt" "$VAMP_APACHE_PROJ_CONF"
replace_token 'VAMP_SSL_KEY' "\/etc\/apache2\/ssl\/$VAMP_WORKING_DOMAIN.key" "$VAMP_APACHE_PROJ_CONF"
ln -s "$VAMP_APACHE_PROJ_CONF" "/etc/apache2/sites-enabled/$VAMP_WORKING_DOMAIN.conf"

rm -R "/var/www/html"
rm "/etc/apache2/sites-available/000-default.conf"
rm "/etc/apache2/sites-enabled/000-default.conf"
rm "/etc/apache/2/sites-available/default-ssl.conf"
service apache2 restart

# Install PHP
print_status "Installing PHP"
echo "VAMP_PHP5_VS_7: $VAMP_PHP5_VS_7"
if [ "$VAMP_PHP5_VS_7" == "true" ]; then
    install_pkg php5 $V_PHP5
    install_pkg libapache2-mod-php5 $V_PHP5
    install_pkg php5-mcrypt $V_PHP5
    install_pkg php5-curl $V_PHP5
    install_pkg php5-imagick $V_PHP5_IMAGICK
    
    cp /vagrant/config/php/5.0/php.ini /etc/php5/apache2/php.ini
else
    cd /tmp
    wget https://www.dotdeb.org/dotdeb.gpg
    apt-key add dotdeb.gpg
    add-apt-repository 'deb http://packages.dotdeb.org jessie all'
    apt-get -y -q update

    install_pkg php7.0 $V_PHP7
    install_pkg php7.0-mcrypt $V_PHP7
    install_pkg php7.0-curl $V_PHP7
    install_pkg php7.0-imagick $V_PHP7_IMAGICK

    cp /vagrant/config/php/7.0/php.ini /etc/php/7.0/apache2/php.ini

    # This Apache configuration tweak is neccessary for PHP7
    a2dismod mpm_event
    a2enmod mpm_prefork
fi
service apache2 restart

# Install MariaDB

# Set default inputs for MariaDB installation prompts.
print_status "Configuring MariaDB installation answers"

debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password password $VAMP_DB_PASS"
debconf-set-selections <<< "mariadb-server-10.0 mysql-server/root_password_again password $VAMP_DB_PASS"

# Add apt-keys for the MariaDB repository.
print_status "Adding MariaDB installation keys and repository location"
apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
add-apt-repository 'deb https://mirrors.evowise.com/mariadb/repo/10.1/debian sid main'
apt-get -y -q update

# Install the MariaDB packages
print_status "Installing MariaDB"
install_pkg mariadb-server $V_MARIA_DB '--force-yes'
install_pkg mariadb-client $V_MARIA_DB '--force-yes'

# Install Postfix or MailCatcher
if [ "$VAMP_IS_DEV" == "false" ]; then
    print_status "Installing Postfix"

    install_pkg postfix $V_POSTFIX
    # TODO: Configure Postfix.
else
    print_status "Installing MailCatcher"

    install_ruby_gem mailcatcher $V_MAILCATCHER

    mailcatcher --http-ip 0.0.0.0
fi

# Install XDebug
print_status "Installing XDebug"

if [ "$VAMP_IS_DEV" == "true" ]; then
    if [ "$VAMP_PHP5_VS_7" == "true" ]; then
        install_pkg php5-xdebug $V_PHP5_XDEBUG
    else
        install_pkg php7.0-xdebug $V_PHP7_XDEBUG
    fi
fi
service apache2 restart