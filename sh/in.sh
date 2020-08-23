#!/bin/bash
# Checking for root
if [[ $EUID -ne 0 ]]; then
   echo "Run as root."
   exit 1
fi

# Installing the Connection Manager
#curl -s https://packagecloud.io/install/repositories/asbru-cm/asbru-cm/script.deb.sh | sudo bash
#sudo apt install asbru-cm

echo "Hello World."
sudo apt-get update -y
sudo apt-get upgrade -y
