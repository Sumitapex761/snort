#!/bin/bash

# Snort 2.9.20 Full Installation and Configuration Script

set -e

# STEP 1: Install dependencies
sudo apt update
sudo apt install -y \
  build-essential libpcap-dev libpcre3-dev libdumbnet-dev bison flex zlib1g-dev \
  liblzma-dev openssl libssl-dev libnghttp2-dev libtool autoconf liblua5.1-dev pkg-config \
  libhwloc-dev cmake libtirpc-dev curl

# STEP 2: Create source directory
sudo mkdir -p /usr/src/snort_src
sudo chown $USER:$USER /usr/src/snort_src
cd /usr/src/snort_src

# STEP 3: Install DAQ
curl -L -k https://www.snort.org/downloads/snort/daq-2.0.7.tar.gz -o daq-2.0.7.tar.gz
tar -xvzf daq-2.0.7.tar.gz
cd daq-2.0.7
./configure
make
sudo make install
sudo ldconfig

# STEP 4: Install Snort
cd /usr/src/snort_src
curl -L -k https://www.snort.org/downloads/snort/snort-2.9.20.tar.gz -o snort-2.9.20.tar.gz
tar -xvzf snort-2.9.20.tar.gz
cd snort-2.9.20
CPPFLAGS="-I/usr/include/tirpc" ./configure --enable-sourcefire --disable-open-appid
make
sudo make install
sudo ldconfig

# STEP 5: Verify Snort installation
snort -V

# STEP 6: Create required directories and files
sudo mkdir -p /etc/snort/rules
sudo mkdir -p /etc/snort/preproc_rules
sudo mkdir -p /etc/snort/so_rules
sudo mkdir -p /usr/local/lib/snort_dynamicrules
sudo mkdir -p /var/log/snort

sudo touch /etc/snort/rules/local.rules
sudo touch /etc/snort/rules/white_list.rules
sudo touch /etc/snort/rules/black_list.rules

# STEP 7: Copy default config files
cd /usr/src/snort_src/snort-2.9.20
sudo cp etc/*.conf* /etc/snort/
sudo cp etc/*.map /etc/snort/

# STEP 8: Create snort user and set permissions
sudo groupadd snort
sudo useradd snort -r -s /usr/sbin/nologin -c SNORT_IDS -g snort

sudo chmod -R 5775 /etc/snort /var/log/snort /usr/local/lib/snort_dynamicrules
sudo chown -R snort:snort /etc/snort /var/log/snort /usr/local/lib/snort_dynamicrules

# DONE

echo "\nSnort 2.9.20 installation complete. Now configure snort.conf and local.rules manually."






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






