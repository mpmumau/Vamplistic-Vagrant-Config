<!---
=====================================================
 _    _      ______  ______  _ _           _         
| |  | |/\  |  ___ \(_____ \| (_)     _   (_)        
| |  | /  \ | | _ | |_____) | |_  ___| |_  _  ____   
\ \/ / /\ \| || || |  ____/| | |/___|  _)| |/ ___)   
 \  | |__| | || || | |     | | |___ | |__| ( (___    
  \/|______|_||_||_|_|     |_|_(___/ \___|_|\____)   
                                                     
=====================================================
-->

Author: Matt Mumau <mpmumau@gmail.com> )
Created: August 29, 2017 )
License: MIT License (included in LICENSE file)
====================================================================)

# VAMPlistic

A Vagrant configuration to boot up a simplistic Debian instance, with vanilla 
Apache, PHP and MariaDB pre-installed and pre-configured. 

Packages which may be installed additionally include XDebug, for debugging PHP
code locally, Node.js for running build scripts and MailCatcher, for debugging 
email transmission locally.

## Configuration

You may modify the file `env.sh` located in the root directory of your Vamplistic
application in order to configure various aspects of your Vamplistic installation.
These include:

- `VAMP_APP_NAME` This will be the name by which the application will be referred
in various instances throughout the provisioning process.

- `VAMP_APP_DOMAIN` This is the domain name for the application. Note that the 
top-level domain (e.g. `.com`, `.net` or `.org`) for the applpication will be 
replaced by `.dev` on the local dev environment.

- `VAMP_DB_USER` and `VAMP_DB_PASS` These are the MariaDB database credentials 
with which the application communicates with the server. Note that this is for 
local dev purposes only.

- `VAMP_IS_DEV` Whether or not this is the local dev version of the application.

- `VAMP_PHP5_VS_7` Whether or not to install PHP5 or PHP7.

## Usage
1. Ensure that you have confirmed desired settings for the application with the
above-described configuration process.

2. You must have Vagrant and Virtualbox installed on your local computer.
Consult the documentation web sites for those projects for more information.

- Vagrant installation: `https://www.vagrantup.com/docs/installation`
- VirtualBox installation: `https://www.virtualbox.org/manual/ch02.html`

3. Clone or download the Vamplistic (this) repository into a local directory of 
your choosing.

4. Navigate to the Vamplistic directory from your local machine's terminal (e.g.
`cd /home/youruser/Documents/vamplistic`).

5. Issue the command `vagrant up`. The Vagrant process will then download
the machine's image, install the image in VirtualBox, and provision and 
configure the Vagrant machine. **Note:** This step may take some time, 
depending  on your current internet bandwidth, as it requires downloading large
packages.

6. Enter the machine's terminal via SSH by typing "vagrant ssh". You will then 
be at a command prompt from within the Vagrant instance's virtual machine.

7. Dev away!

## Shared files

Shared files are meant to be placed in the `shared` subdirectory of the main
Vagrant directory.

All web application files, to be served by Apache, should be placed in the 
`project` folder. Note that this repository will include some default HTML
files for testing purposes, but these should be removed and replaced with your
web application.

## Apache Configuration

By default, Apache will be installed and configured to serve a web application 
from the `shared/project` directory. PHP files will be executed, and all
standard web files will be served from there.

Apache will be configured to run over HTTPS as well as HTTP. All web requests
to HTTP addresses will be configured to run over HTTPS. During the 
provisioning process, all certificates for local dev will be generated.

Logs for the Apache server will be located in the `/var/log/apache2` directory
labeled by the application domain name specified in the `env.sh` configuration 
file (e.g. `vamplistic.dev.error.log` and `vamplistic.dev.access.log`.)

The default configuration for Apache will overridden by the 
`config/apache2/000-default.conf` Apache configuration file. If you need to 
make special adjustments to your application's Apache configuration, it is 
recommend that you use an `.htaccess` file in the root directory of your 
application. However, you may make domain-level configuration adjustments,
you may modify the above-mentioned Apache configuration file, and 
reprovision the server with the `vagrant up --provision` command.

## PHP Configuration

Either PHP5 or PHP7 will be installed on the Vamplistic application system,
depending on the configuration variable you set in `env.sh`.

The default configuration for PHP will be written from either the 
`config/php/5.0/php.ini` file or the `config/php/7.0/php.ini` file. You may 
make global configuration adjustments to PHP by modifying the appropriate
configuration file.

## MariaDB Configuration

MariaDB will be installed and configured to include a user with the given
user and password, and given access to the database, as specified in the
`env.sh` file. Likewise, environment variables will be configured during
the provisioning phase in order to give PHP (and potentially other
applications) access to that database.

## Xdebug

## MailCatcher

## Postfix

## Node.js

## Notes

**Versioning** All installed packages of Vamplistic will be version locked
to the versions specified in the `provision.sh` script. This is done by
design, such that the most consistent possible Vagrant installation
is attained. Philosophically, Vagrant will aim to maintain consistant
performance by adhering only to fully tested and compatible upgrades
to required application packages.

