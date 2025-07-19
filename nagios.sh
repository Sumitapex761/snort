#here nagios setup 

#!/bin/bash

set -e  # Exit on any error

echo "[*] Updating system and installing dependencies..."
sudo apt-get update -y
sudo apt-get install -y apache2 apache2-utils autoconf gcc libc6 libgd-dev make php python3 tree unzip wget libkrb5-dev openssl libssl-dev ca-certificates

echo "[*] Downloading Nagios Core 4.5.1..."
cd /tmp
wget --no-check-certificate https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.1.tar.gz
tar -zxf nagios-4.5.1.tar.gz
cd nagios-4.5.1

echo "[*] Configuring and building Nagios..."
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled/
sudo make all
sudo make install-groups-users
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

echo "[*] Creating Nagios user and password..."
sudo passwd nagios
sudo usermod -a -G nagios www-data

echo "[*] Enabling Apache CGI and rewrite modules..."
sudo a2enmod cgi
sudo a2enmod rewrite

echo "[*] Creating Nagios admin web login..."
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

echo "[*] Verifying Nagios config..."
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

echo "[*] Restarting services..."
sudo systemctl restart nagios
sudo systemctl restart apache2

echo "[*] Installing Nagios Plugins 2.4.0..."
cd /tmp
wget https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.0/nagios-plugins-2.4.0.tar.gz
tar -xvzf nagios-plugins-2.4.0.tar.gz
cd nagios-plugins-2.4.0
./configure
make
sudo make install

echo "[*] Installing extra dependencies for plugins (optional)..."
sudo apt-get install -y automake autotools-dev bc build-essential dc gawk gettext libmcrypt-dev libnet-snmp-perl libssl-dev snmp

echo "[*] Downloading check_ncpa.py plugin..."
cd /usr/local/nagios/libexec/
wget https://assets.nagios.com/downloads/ncpa/check_ncpa.tar.gz
tar -xzf check_ncpa.tar.gz

echo "[✔] Nagios Core + Plugins + NCPA plugin setup complete!"

