
#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 25-Oct-2023
#
curl -fsSL https://get.docker.com/ | sh
sudo systemctl start docker
sudo systemctl status docker
docker pull drachtio/drachtio-server
mkdir -p /root/build
cd /root/build
yum install -y git
curl -sL https://rpm.nodesource.com/setup_14.x | sudo bash -
yum install nodejs -y
sudo yum install -y epel-release 
sudo yum install -y redis
sudo systemctl start redis.service
sudo systemctl enable redis
sudo systemctl status redis.service
node -v
git clone https://github.com/drachtio/drachtio-siprec-recording-server.git siprec-recording-server
cd siprec-recording-server
npm install
git clone https://github.com/kietcaodev/siprec.git
mv config config.bk
mv lib lib.bk
cp -r siprec/config config 
cp -r siprec/lib lib
sudo npm install -g forever
npm list forever -g
chmod -v +x /etc/rc.local
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
docker run -d --rm --name drachtio --net=host \
drachtio/drachtio-server drachtio --loglevel debug --contact "sip:*;transport=udp" 
cd /root/build/siprec-recording-server
forever start app.js' > /etc/rc.local
