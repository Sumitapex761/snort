# ncpa
#!/bin/bash

cd /tmp
wget https://assets.nagios.com/downloads/ncpa3/ncpa-latest-1.amd64.deb


sudo apt update
sudo apt install ./ncpa-latest-1.amd64.deb -y



#sudo nano /usr/local/ncpa/etc/ncpa.cfg
#community_string = mytoken
#🔁 Change it to:
#community_string = Password1234


sudo systemctl daemon-reexec
sudo systemctl daemon-reload

