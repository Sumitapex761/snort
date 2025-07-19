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
