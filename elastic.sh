#!bin/bash/
sudo apt update -y
sudo apt install default-jdk  wget -y

# Download the latest .deb package (you can also get it from https://www.elastic.co/downloads/elasticsearch)
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.13.4-amd64.deb
sudo dpkg -i elasticsearch-8.13.4-amd64.deb

#Edit in inthe  
#sudo nano /etc/elasticsearch/elasticsearch.yml

#cluster.name: my-application
#node.name: node-1
#network.host: 0.0.0.0
#discovery.seed_hosts: ["127.0.0.1"]


# Comment this if you're running a single node
# cluster.initial_master_nodes: ["node-1", "node-2"]

# Disable security
#xpack.security.enabled: false
#xpack.security.enrollment.enabled: false
#xpack.security.http.ssl.enabled: false
#xpack.security.transport.ssl.enabled: false


sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable --now elasticsearch


sudo apt update -y
sudo apt install -y apt-transport-https wget gnupg curl


wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list

sudo apt update 
sudo apt install logstash -y

sudo systemctl enable logstash
sudo systemctl start logstash



wget https://artifacts.elastic.co/downloads/kibana/kibana-8.13.4-amd64.deb
sudo dpkg -i kibana-8.13.4-amd64.deb
sudo systemctl enable --now kibana
#sudo nano /etc/kibana/kibana.yml

#Uncomment aLL 
#server.port: 5601
#server.host: "0.0.0.0"
#elasticsearch.hosts: ["http://localhost:9200"]



sudo systemctl restart  logstash
sudo systemctl restart  elasticsearch
sudo systemctl restart kibana
