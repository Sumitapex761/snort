#!/bin/bash

set -e  # Stop on error

echo "[*] Updating system and installing core dependencies..."
sudo apt-get update -y
sudo apt-get install -y apache2 apache2-utils autoconf gcc libc6 libgd-dev make php \
                        python3 tree unzip wget libkrb5-dev openssl libssl-dev ca-certificates \
                        libapache2-mod-php libtool unzip libmcrypt-dev libnet-snmp-perl snmp \
                        gettext automake autotools-dev bc build-essential dc gawk libcurl4-openssl-dev

echo "[*] Downloading Nagios Core 4.5.1..."
cd /tmp
wget --no-check-certificate https://assets.nagios.com/downloads/nagioscore/releases/nagios-4.5.1.tar.gz
tar -zxf nagios-4.5.1.tar.gz
cd nagios-4.5.1

echo "[*] Configuring and building Nagios Core..."
sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled/
sudo make all
sudo make install-groups-users
sudo make install
sudo make install-daemoninit
sudo make install-commandmode
sudo make install-config
sudo make install-webconf

echo "[*] Creating Nagios user password..."
sudo passwd nagios

echo "[*] Adding Apache user to Nagios group..."
sudo usermod -a -G nagios www-data

echo "[*] Enabling Apache modules..."
sudo a2enmod cgi
sudo a2enmod rewrite

echo "[*] Creating Nagios web UI login..."
sudo htpasswd -c /usr/local/nagios/etc/htpasswd.users nagiosadmin

echo "[*] Verifying Nagios configuration..."
sudo /usr/local/nagios/bin/nagios -v /usr/local/nagios/etc/nagios.cfg

echo "[*] Restarting Apache and Nagios..."
sudo systemctl restart apache2
sudo systemctl enable apache2
sudo systemctl restart nagios
sudo systemctl enable nagios

echo "[*] Downloading Nagios Plugins 2.4.0..."
cd /tmp
wget https://github.com/nagios-plugins/nagios-plugins/releases/download/release-2.4.0/nagios-plugins-2.4.0.tar.gz
tar -xvzf nagios-plugins-2.4.0.tar.gz
cd nagios-plugins-2.4.0

echo "[*] Patching missing 'min_state()' function in check_disk.c..."
sed -i '/^#include/a int min_state(int a, int b);' plugins/check_disk.c
sed -i '/^int main.*/i int min_state(int a, int b) { return (a < b) ? a : b; }' plugins/check_disk.c

echo "[*] Configuring and installing Nagios Plugins..."
./configure
make
sudo make install

echo "[*] Downloading check_ncpa.py plugin..."
cd /usr/local/nagios/libexec/
sudo wget https://assets.nagios.com/downloads/ncpa/check_ncpa.tar.gz
sudo tar -xzf check_ncpa.tar.gz
sudo rm check_ncpa.tar.gz

echo "[✔] Nagios Core + Plugins + NCPA plugin setup complete!"
echo "---------------------------------------------------------"
echo "💡 Access the Nagios web UI: http://<YOUR-IP>/nagios/"
echo "🔐 Login with user: nagiosadmin and the password you set."
