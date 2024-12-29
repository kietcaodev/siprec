#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 05-Nov-2024
#
echo "*** Begin Script Building SIPREC***"
#Install docker and docker compose
apt -y install sudo
sudo apt update && sudo apt upgrade -y
sudo apt install apt-transport-https ca-certificates curl software-properties-common gnupg2 -y
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
echo "deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list
sudo apt update && sudo apt install docker-ce -y
sudo systemctl enable docker
sudo docker run hello-world
sudo curl -L "https://github.com/docker/compose/releases/download/1.29.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version
#Install siprec-server

docker pull drachtio/drachtio-server
mkdir -p /root/build
cd /root/build
sudo apt install -y git nodejs npm
sleep 5
sudo apt install -y redis
sudo systemctl start redis-server
sudo systemctl enable redis-server
sudo systemctl status redis-server
git clone https://github.com/kietcaodev/drachtio-siprec-recording-server.git
cd siprec-recording-server
echo '{
    "uid": "app",
    "append": true,
    "watch": true,
    "script": "app.js",
    "sourceDir": "/root/build/siprec-recording-server",
    "logFile": "/root/.forever/drachtio-vgw-new.log"
}' > development.json
npm install
git clone https://github.com/kietcaodev/siprec.git
mv config config.bk
mv lib lib.bk
cp -r siprec/config config 
cp -r siprec/lib lib
sudo npm install -g forever
npm list forever -g
echo '#!/bin/bash
# THIS FILE IS ADDED FOR COMPATIBILITY PURPOSES
#
# It is highly advisable to create own systemd services or udev rules
# to run scripts during boot instead of using this file.
#
# In contrast to previous versions due to parallel execution during boot
# this script will NOT be run after all other services.
#
# Please note that you must run 'chmod +x /etc/rc.d/rc.local' to ensure
# that this script will be executed during boot.

touch /var/lock/subsys/local
docker run -d --rm --name drachtio-vgw-new --net=host \
drachtio/drachtio-server drachtio --loglevel notice --sofia-loglevel 0 --contact "sip:*;transport=udp" 
cd /root/build/siprec-recording-server
forever start development.json' > /etc/rc.local
chmod -v +x /etc/rc.local
systemctl restart rc-local
systemctl status rc-local
sleep 5
node -v
docker image ls
echo "*** End Script***"
echo "*** Congratulations! SIPREC has been installed, listen udp:5060 ***"
