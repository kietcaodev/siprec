yum -y install yum-utils gdb wget net-tools
sudo wget -O /etc/yum.repos.d/kamailio.repo http://download.opensuse.org/repositories/home:/kamailio:/v5.6.x-rpms/CentOS_7/home:kamailio:v5.6.x-rpms.repo
sudo yum install vim kamailio kamailio-presence kamailio-ldap kamailio-mysql kamailio-debuginfo kamailio-xmpp kamailio-unixodbc kamailio-utils kamailio-tls kamailio-outbound kamailio-gzcompress -y
kamailio --version
echo '[irontec]
name=Irontec RPMs repository
baseurl=http://packages.irontec.com/centos/$releasever/$basearch/' > /etc/yum.repos.d/irontec.repo
rpm --import http://packages.irontec.com/public.key
yum install sngrep -y
cp -r /etc/kamailio /etc/kamailio.bk
mv /etc/kamailio/kamctlrc /etc/kamailio/kamctlrc.bk

