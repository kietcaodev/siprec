
#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 25-Oct-2023
# BasebsPBX Hight Availability with MariaDB Replica, Corosync, PCS, Pacemaker and Lsync
#
set -e
function jumpto
{
    label=$start
    cmd=$(sed -n "/$label:/{:a;n;p;ba};" $0 | grep -v ':$')
    eval "$cmd"
    exit
}

echo -e "\n"
echo -e "************************************************************"
echo -e "*   Welcome to the Basebs high availability installation   *"
echo -e "*                All options are mandatory                 *"
echo -e "************************************************************"

filename="config.txt"
if [ -f $filename ]; then
	echo -e "config file"
	n=1
	while read line; do
		case $n in
			1)
				ip_master=$line
  			;;
			2)
				ip_standby=$line
  			;;
			3)
				ip_floating=$line
  			;;
			4)
				hostname_master=$line
  			;;
			5)
				hostname_standby=$line
			;;	
			6)
				hapassword=$line
  			;;
			7)
				mysql_root_password=$line
  			;;
			8)
				ntp_time=$line
  			;;
		esac
		n=$((n+1))
	done < $filename
	echo -e "IP Master................ > $ip_master"	
	echo -e "IP Standby............... > $ip_standby"
	echo -e "Virtual IP............... > $ip_floating "
	echo -e "Hostname Master.......... > $hostname_master"
	echo -e "Hostname Standby......... > $hostname_standby"
	echo -e "hacluster password....... > $hapassword"
	echo -e "mysql password........... > $mysql_root_password"
	echo -e "ntp time server.......... > $ntp_time"
fi

while [[ $ip_master == '' ]]
do
    read -p "IP Master................ > " ip_master 
done 

while [[ $ip_standby == '' ]]
do
    read -p "IP Standby............... > " ip_standby 
done

while [[ $ip_floating == '' ]]
do
    read -p "Virtual IP............... > " ip_floating 
done 

while [[ $hostname_master == '' ]]
do
    read -p "Hostname Master.......... > " hostname_master
done 

while [[ $hostname_standby == '' ]]
do
    read -p "Hostname Standby......... > " hostname_standby
done 

while [[ $hapassword == '' ]]
do
    read -p "hacluster password....... > " hapassword 
done

while [[ $mysql_root_password == '' ]]
do
    read -p "mysql password........... > " mysql_root_password 
done

while [[ $ntp_time == '' ]]
do
    read -p "ntp time server.......... > " ntp_time 
done


echo -e "************************************************************"
echo -e "*                   Check Information                      *"
echo -e "*        Make sure you have internet on both servers       *"
echo -e "************************************************************"
while [[ $veryfy_info != yes && $veryfy_info != no ]]
do
    read -p "Are you sure to continue with this settings? (yes,no) > " veryfy_info 
done

if [ "$veryfy_info" = yes ] ;then
	echo -e "************************************************************"
	echo -e "*                Starting to run the scripts               *"
	echo -e "************************************************************"
else
    	exit;
fi

cat > config.txt << EOF
$ip_master
$ip_standby
$ip_floating
$hostname_master
$hostname_standby
$hapassword
$mysql_root_password
$ntp_time
EOF

cat > /etc/profile.d/basebswelcome.sh << EOF
#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 30-Sep-2022
# Show the Role of Server.
#Bash Colour Codes
green="\033[00;32m"
txtrst="\033[00;0m"
if [ -f /etc/redhat-release ]; then
        linux_ver=\`cat /etc/redhat-release\`
        basebspbx_ver=\`rpm -qi basebspbx |awk -F: '/^Version/ {print \$2}'\`
        basebspbx_release=\`rpm -qi basebspbx |awk -F: '/^Release/ {print \$2}'\`
elif [ -f /etc/debian_version ]; then
        linux_ver="Debian "\`cat /etc/debian_version\`
        basebspbx_ver=\`dpkg -l basebspbx |awk '/ombutel/ {print \$3}'\`
else
        linux_ver=""
        basebspbx_ver=""
        basebspbx_release=""
fi
bpbx_version="KietCT_HA_Ver1"
logo='
 ____                 ____ ____    ____  ______  __
| __ )  __ _ ___  ___| __ ) ___|  |  _ \| __ ) \/ /	
|  _ \ / _,  / __|/ _ \  _ \___ \  | |_) |  _ \\  /	
| |_) | (_| \__ \  __/ |_) |__) | |  __/| |_) /  \	
|____/ \__,_|___/\___|____/____/  |_|   |____/_/\_\	 
'
echo -e "
\${green}
\${logo}
\${txtrst}
 Version        : \${bpbx_version//[[:space:]]}
 Linux Version  : \${linux_ver}
 Welcome to     : \`hostname\`
 Uptime         : \`uptime | grep -ohe 'up .*' | sed 's/up //g' | awk -F "," '{print \$1}'\`
 Load           : \`uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print "Last Minute: " \$3" Last 5 Minutes: "\$4" Last 15 Minutes: "\$5 }'\`
 Users          : \`uptime | grep -ohe '[0-9.*] user[s,]'\`
 IP Address     : \${green}\`ip addr | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | xargs\`\${txtrst}
 Clock          :\`timedatectl | sed -n '/Local time/ s/^[ \t]*Local time:\(.*$\)/\1/p'\`
 NTP Sync.      :\`timedatectl |awk -F: '/NTP sync/ {print \$2}'\`
"
EOF
chmod 755 /etc/profile.d/basebswelcome.sh
scp /etc/profile.d/basebswelcome.sh root@$ip_standby:/etc/profile.d/basebswelcome.sh
ssh root@$ip_standby "chmod 755 /etc/profile.d/basebswelcome.sh"

stepFile=step.txt
if [ -f $stepFile ]; then
	step=`cat $stepFile`
else
	step=0
fi

echo -e "Start in step: " $step

start="check_selinux"
case $step in
	1)
		start="check_selinux"
  	;;
	2)
		start="check_firewalld"
  	;;
	3)
		start="hostname"
  	;;
	4)
		start="install_ntpd"
  	;;
	5)
		start="install_mariadb"
	;;
	6)
		start="install_kamalio"
  	;;
	7)
		start="install_docker_siprec"
  	;;
	8)
		start="create_lsyncd_config_file"
  	;;
	9)
		start="create_mariadb_replica"
  	;;
	10)
		start="create_hacluster_password"
  	;;
	11)
		start="starting_pcs"
  	;;
	12)
		start="auth_hacluster"
	;;
	13)
		start="creating_cluster"
	;;
	14)
		start="starting_cluster"
	;;
	15)
		start="creating_floating_ip"
	;;
	16)
		start="disable_services"
		;;
	17)
		start="create_kamailio_service"
		;;
	18)	
		start="create_docker_service"
	;;	
	19)	
		start="create_lsyncd_service"
	;;	
	20)	
		start="basebspbx_create_bascul"
	;;	
	21)	
		start="basebspbx_create_role"
	;;
	22)	
		start="create_welcome_message"
	;;
esac
jumpto $start
echo -e "*** Done Step 1 ***"
echo -e "1"	> step.txt

check_selinux:
echo -e "************************************************************"
echo -e "*              Check Selinux in Master and Standby         *"
echo -e "************************************************************"
master_sestatus=$(getenforce)
if [ "$master_sestatus" == "Disabled" ] ;then
	echo -e "master_sestatus $master_sestatus"
	echo -e "Selinux Master Good. Continue..."
else
	echo -e "Selinux Master is enable, You must disable SeLinux"
	echo -e "Execute disable selinux Master"
	sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config
	echo -e "Done disable selinux Master"
	echo -e "You must reboot server Master "
	echo -e "************************************************************"
	echo -e "*                     sudo shutdown -r now                 *"
	echo -e "************************************************************"
    exit;
fi	

standby_sestatus=`ssh root@$ip_standby 'getenforce'`
if [ "$standby_sestatus" == "Disabled" ] ;then
	echo -e "standby_sestatus $standby_sestatus"
	echo -e "Selinux Standby Good. Continue..."
else
	echo -e "Selinux Standby is enable, You must disable SeLinux"
	echo -e "Execute disable selinux Standby"
	ssh root@$ip_standby 'sudo sed -i 's/enforcing/disabled/g' /etc/selinux/config /etc/selinux/config'
	echo -e "Done disable selinux Standby"
	echo -e "You must reboot server Standby"
	echo -e "************************************************************"
	echo -e "*       ssh root@$ip_standby 'sudo shutdown -r now'        *"
	echo -e "************************************************************"
    exit;
fi
echo -e "*** Done check Selinux ***"
echo -e "*** Done Step 2 ***"
echo -e "2"	> step.txt

check_firewalld:
echo -e "************************************************************"
echo -e "*            Turn off Firewalld in Master and Standby      *"
echo -e "************************************************************"
systemctl stop firewalld
systemctl disable firewalld
echo -e "************************************************************"
echo -e "*             Configuring Permanent Firewall               *"
echo -e "*   Creating Firewall Rules in BasebsPBX in Server Master  *"
echo -e "************************************************************"
ssh root@$ip_standby 'systemctl stop firewalld'
ssh root@$ip_standby 'systemctl disable firewalld'
echo -e "************************************************************"
echo -e "*             Configuring Permanent Firewall               *"
echo -e "*  Creating Firewall Rules in BasebsPBX in Server Standby  *"
echo -e "************************************************************"
echo -e "*** Done Step 3 ***"
echo -e "3"	> step.txt

hostname:
echo -e "************************************************************"
echo -e "*            Get the hostname in Master and Standby         *"
echo -e "************************************************************"
hostnamectl set-hostname "$hostname_master"
ssh root@$ip_standby "hostnamectl set-hostname $hostname_standby"
host_master=`hostname -f`
host_standby=`ssh root@$ip_standby 'hostname -f'`
echo -e "$host_master"
echo -e "$host_standby"
echo -e "$ip_master \t$host_master" >> /etc/hosts
echo -e "$ip_standby \t$host_standby" >> /etc/hosts
ssh root@$ip_standby "echo -e '$ip_master \t$host_master' >> /etc/hosts"
ssh root@$ip_standby "echo -e '$ip_standby \t$host_standby' >> /etc/hosts"
echo -e "*** Done Hostname Master and Standby***"
echo -e "*** Done Step 4 ***"
echo -e "4"	> step.txt

install_ntpd:
echo -e "************************************************************"
echo -e "*                     Install NTP Time                     *"
echo -e "************************************************************"
echo -e "************************************************************"
echo -e "*           Creating NTP time in Server Master            *"
echo -e "************************************************************"
yum install ntp -y 
yum install -y chrony 
systemctl enable ntpd
systemctl enable chronyd 
systemctl restart chronyd 
systemctl restart ntpd 
sleep 5
ntpdate -q "$ntp_time"
sleep 5
timedatectl
echo -e "************************************************************"
echo -e "*           Creating NTP time in Server Standby            *"
echo -e "************************************************************"
ssh root@$ip_standby 'yum install ntp -y'
ssh root@$ip_standby 'yum install -y chrony' 
ssh root@$ip_standby 'systemctl enable ntpd'
ssh root@$ip_standby 'systemctl enable chronyd' 
ssh root@$ip_standby 'systemctl restart chronyd'
ssh root@$ip_standby 'systemctl restart ntpd' 
ssh root@$ip_standby 'sleep 5'
ssh root@$ip_standby "ntpdate -q $ntp_time"
ssh root@$ip_standby 'sleep '5
ssh root@$ip_standby 'timedatectl'
echo -e "*** Done Step 5 ***"
echo -e "5"	> step.txt

install_mariadb:
echo -e "************************************************************"
echo -e "*                     Install Mariadb                      *"
echo -e "************************************************************"
echo -e "************************************************************"
echo -e "*            Install mariadb in Server Master              *"
echo -e "************************************************************"
yum install -y wget
ssh root@$ip_standby "yum install -y wget"
wget https://raw.githubusercontent.com/kietcaodev/siprec/main/mariadb_pass.sh
sleep 10
sed -i "s/mariadb_pass/$mysql_root_password/" mariadb_pass.sh
cp mariadb_pass.sh /tmp/mariadb_pass.sh
chmod +x /tmp/mariadb_pass.sh
/tmp/./mariadb_pass.sh
echo -e "************************************************************"
echo -e "*            Install mariadb in Server Standby             *"
echo -e "************************************************************"
scp /tmp/mariadb_pass.sh root@$ip_standby:/tmp/mariadb_pass.sh
ssh root@$ip_standby "chmod +x /tmp/mariadb_pass.sh"
ssh root@$ip_standby "/tmp/./mariadb_pass.sh"
echo -e "*** Done Step 6 ***"
echo -e "6"	> step.txt

install_kamalio:
echo -e "************************************************************"
echo -e "*                     Install Kamailio                     *"
echo -e "************************************************************"
echo -e "************************************************************"
echo -e "*            Install Kamailio in Server Master             *"
echo -e "************************************************************"
wget https://raw.githubusercontent.com/kietcaodev/siprec/main/install_kama.sh
sleep 10
cp install_kama.sh /tmp/install_kama.sh
chmod +x /tmp/install_kama.sh
/tmp/./install_kama.sh
wget https://raw.githubusercontent.com/kietcaodev/siprec/main/kamctlrc
sleep 10
cp kamctlrc /etc/kamailio/kamctlrc
wget https://raw.githubusercontent.com/kietcaodev/siprec/main/kama_db.sh
sleep 10
sed -i "s/mariadb_pass/$mysql_root_password/" kama_db.sh
cp kama_db.sh /tmp/kama_db.sh
chmod +x /tmp/kama_db.sh
/tmp/./kama_db.sh
sudo systemctl restart kamailio
sudo systemctl enable kamailio
sudo systemctl status kamailio
echo -e "************************************************************"
echo -e "*            Install Kamailio in Server Standby             *"
echo -e "************************************************************"
scp /tmp/install_kama.sh root@$ip_standby:/tmp/install_kama.sh
scp /tmp/kama_db.sh root@$ip_standby:/tmp/kama_db.sh
ssh root@$ip_standby "chmod +x /tmp/install_kama.sh"
sleep 5
ssh root@$ip_standby "/tmp/./install_kama.sh"
ssh root@$ip_standby "sleep 5"
sleep 5
scp /etc/kamailio/kamctlrc root@$ip_standby:/etc/kamailio/kamctlrc
ssh root@$ip_standby "chmod +x /tmp/kama_db.sh"
ssh root@$ip_standby "/tmp/./kama_db.sh"
ssh root@$ip_standby "sudo systemctl restart kamailio"
ssh root@$ip_standby "sudo systemctl enable kamailio"
ssh root@$ip_standby "sudo systemctl status kamailio"
echo -e "************************************************************"
echo -e "*                  Done Install Kamailio                   *"
echo -e "************************************************************"
echo -e "*** Done Step 7 ***"
echo -e "7"	> step.txt

install_docker_siprec:
echo -e "************************************************************"
echo -e "*               Install Docker,SIPREC                      *"
echo -e "************************************************************"
echo -e "************************************************************"
echo -e "*         Install Docker,SIPREC in Server Master           *"
echo -e "************************************************************"
curl -fsSL https://raw.githubusercontent.com/kietcaodev/siprec/main/siprec.sh | sh
echo -e "************************************************************"
echo -e "*         Install Docker,SIPREC in Server Standby          *"
echo -e "************************************************************"
ssh root@$ip_standby "mkdir -p /root/build/"
ssh root@$ip_standby "cd /root/build/"
ssh root@$ip_standby "curl -fsSL https://raw.githubusercontent.com/kietcaodev/siprec/main/siprec.sh | sh"
echo -e "*** Done Step 8 ***"
echo -e "8"	> step.txt

create_lsyncd_config_file:
echo -e "************************************************************"
echo -e "*          Configure lsync in Server 1 and 2               *"
echo -e "************************************************************"


sysctl -w fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p
ssh root@$ip_standby "sysctl -w fs.inotify.max_user_watches=524288 | tee -a /etc/sysctl.conf && sysctl -p"
cat > /etc/lsyncd.conf << EOF
----
-- User configuration file for lsyncd.
--
-- Simple example for default rsync.
--
settings {
		logfile    = "/var/log/lsyncd/lsyncd.log",
		statusFile = "/var/log/lsyncd/lsyncd-status.log",
		statusInterval = 20,
		nodaemon   = true,
		insist = true,
}


sync {
		default.rsync,
		source="/etc/kamailio/",
		target="$ip_standby:/etc/kamailio/",
		rsync={
				owner = true,
				group = true
		}
}


sync {
		default.rsync,
		source="/var/lib/kamailio/",
		target="$ip_standby:/var/lib/kamailio/",
		rsync={
				owner = true,
				group = true
		}
}

sync {
		default.rsync,
		source="/usr/share/kamailio/",
		target="$ip_standby:/usr/share/kamailio/",
		rsync={
				owner = true,
				group = true
		}
}
sync {
		default.rsync,
		source="/root/build/",
		target="$ip_standby:/root/build/",
		rsync={
				owner = true,
				group = true
		}		
}


EOF
cat > /tmp/lsyncd.conf << EOF
----
-- User configuration file for lsyncd.
--
-- Simple example for default rsync.
--
settings {
		logfile    = "/var/log/lsyncd/lsyncd.log",
		statusFile = "/var/log/lsyncd/lsyncd-status.log",
		statusInterval = 20,
		nodaemon   = true,
		insist = true,
}

sync {
		default.rsync,
		source="/etc/kamailio/",
		target="$ip_master:/etc/kamailio/",
		rsync={
				owner = true,
				group = true
		}
}

sync {
		default.rsync,
		source="/var/lib/kamailio/",
		target="$ip_master:/var/lib/kamailio/",
		rsync={
				owner = true,
				group = true
		}
}

sync {
		default.rsync,
		source="/usr/share/kamailio/",
		target="$ip_master:/usr/share/kamailio/",
		rsync={
				owner = true,
				group = true
		}
}
sync {
		default.rsync,
		source="/root/build/",
		target="$ip_master:/root/build/",
		rsync={
				owner = true,
				group = true
		}				
}


EOF
scp /tmp/lsyncd.conf root@$ip_standby:/etc/lsyncd.conf
echo -e "*** Done Step 9 ***"
echo -e "9"	> step.txt

create_mariadb_replica:
echo -e "************************************************************"
echo -e "*                Create mariadb replica                    *"
echo -e "************************************************************"
#Remove anonymous user from MySQL
mysql -uroot -p$mysql_root_password -e "DELETE FROM mysql.user WHERE User='';"
#Configuration of the First Master Server (Master-1)
cat > /etc/my.cnf.d/basebspbx.cnf << EOF
[mariadb]
server-id=1
log-bin=master
binlog-format=row
binlog-do-db=kamailio
EOF
systemctl restart mariadb
#Create a new user on the Master-1
mysql -uroot -p$mysql_root_password -e "GRANT REPLICATION SLAVE ON *.* to basebs_replica@'%' IDENTIFIED BY 'basebs_replica';"
mysql -uroot -p$mysql_root_password -e "FLUSH PRIVILEGES;"
mysql -uroot -p$mysql_root_password -e "FLUSH TABLES WITH READ LOCK;"
#Get bin_log on Master-1
file_server_1=`mysql -uroot -p$mysql_root_password -e "show master status" | awk 'NR==2 {print $1}'`
position_server_1=`mysql -uroot -p$mysql_root_password -e "show master status" | awk 'NR==2 {print $2}'`

#Now on the Master-1 server, do a dump of the database MySQL and import it to Master-2
mysqldump -u root -p$mysql_root_password --all-databases > all_databases.sql
scp all_databases.sql root@$ip_standby:/tmp/all_databases.sql
cat > /tmp/mysqldump.sh << EOF
#!/bin/bash
mysql -u root -p$mysql_root_password <  /tmp/all_databases.sql 
EOF
scp /tmp/mysqldump.sh root@$ip_standby:/tmp/mysqldump.sh
ssh root@$ip_standby "chmod +x /tmp/mysqldump.sh"
ssh root@$ip_standby "/tmp/./mysqldump.sh"

#Configuration of the Second Master Server (Master-2)
cat > /tmp/basebspbx.cnf << EOF
[mariadb]
server-id = 2
log-bin=master
binlog-format=row
binlog-do-db=kamailio
EOF
scp /tmp/basebspbx.cnf root@$ip_standby:/etc/my.cnf.d/basebspbx.cnf
ssh root@$ip_standby "systemctl restart mariadb"
#Create a new user on the Master-2
cat > /tmp/grand.sh << EOF
#!/bin/bash
mysql -uroot -p$mysql_root_password -e "GRANT REPLICATION SLAVE ON *.* to basebs_replica@'%' IDENTIFIED BY 'basebs_replica';"
mysql -uroot -p$mysql_root_password -e "FLUSH PRIVILEGES;"
mysql -uroot -p$mysql_root_password -e "FLUSH TABLES WITH READ LOCK;"
EOF
scp /tmp/grand.sh root@$ip_standby:/tmp/grand.sh
ssh root@$ip_standby "chmod +x /tmp/grand.sh"
ssh root@$ip_standby "/tmp/./grand.sh"
#Get bin_log on Master-2
file_server_2=`ssh root@$ip_standby "mysql -uroot -p$mysql_root_password -e 'show master status;'" | awk 'NR==2 {print $1}'`
position_server_2=`ssh root@$ip_standby "mysql -uroot -p$mysql_root_password -e 'show master status;'" | awk 'NR==2 {print $2}'`
#Stop the slave, add Master-1 to the Master-2 and start slave
cat > /tmp/change.sh << EOF
#!/bin/bash
mysql -uroot -p$mysql_root_password -e "STOP SLAVE;"
mysql -uroot -p$mysql_root_password -e "CHANGE MASTER TO MASTER_HOST='$ip_master', MASTER_USER='basebs_replica', MASTER_PASSWORD='basebs_replica', MASTER_LOG_FILE='$file_server_1', MASTER_LOG_POS=$position_server_1;"
mysql -uroot -p$mysql_root_password -e "START SLAVE;"
EOF
scp /tmp/change.sh root@$ip_standby:/tmp/change.sh
ssh root@$ip_standby "chmod +x /tmp/change.sh"
ssh root@$ip_standby "/tmp/./change.sh"

#Connect to Master-1 and follow the same steps
mysql -uroot -p$mysql_root_password -e "STOP SLAVE;"
mysql -uroot -p$mysql_root_password -e "CHANGE MASTER TO MASTER_HOST='$ip_standby', MASTER_USER='basebs_replica', MASTER_PASSWORD='basebs_replica', MASTER_LOG_FILE='$file_server_2', MASTER_LOG_POS=$position_server_2;"
mysql -uroot -p$mysql_root_password -e "START SLAVE;"

echo -e "*** Done Step 10 ***"
echo -e "10"	> step.txt

create_hacluster_password:
echo -e "************************************************************"
echo -e "*     Create password for hacluster in Master/Standby      *"
echo -e "************************************************************"
yum -y install epel-release corosync pacemaker pcs lsyncd
sleep 10
ssh root@$ip_standby "yum -y install epel-release corosync pacemaker pcs lsyncd"
sleep 10
echo $hapassword | passwd --stdin hacluster
ssh root@$ip_standby "echo $hapassword | passwd --stdin hacluster"
echo -e "*** Done Step 11 ***"
echo -e "11"	> step.txt

starting_pcs:
echo -e "************************************************************"
echo -e "*         Starting pcsd services in Master/Standby         *"
echo -e "************************************************************"
systemctl start pcsd
ssh root@$ip_standby "systemctl start pcsd"
systemctl enable pcsd.service 
systemctl enable corosync.service 
systemctl enable pacemaker.service
ssh root@$ip_standby "systemctl enable pcsd.service"
ssh root@$ip_standby "systemctl enable corosync.service"
ssh root@$ip_standby "systemctl enable pacemaker.service"
echo -e "*** Done Step 12 ***"
echo -e "12"	> step.txt

auth_hacluster:
echo -e "************************************************************"
echo -e "*            Server Authenticate in Master                 *"
echo -e "************************************************************"
pcs cluster auth $host_master $host_standby -u hacluster -p $hapassword
echo -e "*** Done Step 13 ***"
echo -e "13"	> step.txt

creating_cluster:
echo -e "************************************************************"
echo -e "*              Creating Cluster in Master                  *"
echo -e "************************************************************"
pcs cluster setup --name cluster_basebspbx $host_master $host_standby
echo -e "*** Done Step 14 ***"
echo -e "14"	> step.txt

starting_cluster:
echo -e "************************************************************"
echo -e "*              Starting Cluster in Master                  *"
echo -e "************************************************************"
pcs cluster start --all
pcs cluster enable --all
pcs property set stonith-enabled=false
pcs property set no-quorum-policy=ignore
echo -e "*** Done Step 15 ***"
echo -e "15"	> step.txt

creating_floating_ip:
echo -e "************************************************************"
echo -e "*            Creating Floating IP in Master                *"
echo -e "************************************************************"
pcs resource create virtual_ip ocf:heartbeat:IPaddr2 ip=$ip_floating cidr_netmask=$ip_floating_mask op monitor interval=30s on-fail=restart
pcs cluster cib drbd_cfg
pcs cluster cib-push drbd_cfg
echo -e "*** Done Step 16 ***"
echo -e "16"	> step.txt

disable_services:
echo -e "************************************************************"
echo -e "*             Disable Services in Server 1 and 2           *"
echo -e "************************************************************"
echo -e "************************************************************"
echo -e "*                 Disable Services in Master               *"
echo -e "************************************************************"
chkconfig kamailio off
service kamailio stop
chkconfig lsyncd off
service lsyncd stop
chkconfig docker off
service docker stop
echo -e "************************************************************"
echo -e "*                 Disable Services in Standby               *"
echo -e "************************************************************"
ssh root@$ip_standby "chkconfig kamailio off"
ssh root@$ip_standby "service kamailio stop"
ssh root@$ip_standby "chkconfig lsyncd off"
ssh root@$ip_standby "service lsyncd stop"
ssh root@$ip_standby "chkconfig docker off"
ssh root@$ip_standby "service docker stop"
echo -e "*** Done Step 17 ***"
echo -e "17"	> step.txt

create_kamailio_service:
echo -e "************************************************************"
echo -e "*     Create kamailio Service in Server 1       *"
echo -e "************************************************************"
sed -i "s/0.0.0.0:5080/$ip_floating:5080/" /etc/kamailio/kamailio.cfg
pcs resource create kamailio service:kamailio op monitor interval=30s
pcs cluster cib fs_cfg
pcs cluster cib-push fs_cfg --config
pcs -f fs_cfg constraint colocation add kamailio with virtual_ip INFINITY
pcs -f fs_cfg constraint order virtual_ip then kamailio
pcs cluster cib-push fs_cfg --config
pcs resource update kamailio op stop timeout=120s
pcs resource update kamailio op start timeout=120s
pcs resource update kamailio op restart timeout=120s

echo -e "*** Done Step 18 ***"
echo -e "18"	> step.txt

create_docker_service:
echo -e "************************************************************"
echo -e "*     Create docker Service in Server 1       *"
echo -e "************************************************************"
pcs resource create docker service:docker op monitor interval=30s
pcs cluster cib fs_cfg
pcs cluster cib-push fs_cfg --config
pcs -f fs_cfg constraint colocation add docker with virtual_ip INFINITY
pcs -f fs_cfg constraint order kamailio then docker
pcs cluster cib-push fs_cfg --config
pcs resource update docker op stop timeout=120s
pcs resource update docker op start timeout=120s
pcs resource update docker op restart timeout=120s

sed -i "s/0.0.0.0/$ip_floating/" /root/build/siprec-recording-server/config/local.json
pcs resource create rc-local service:rc-local op monitor interval=30s
pcs cluster cib fs_cfg
pcs cluster cib-push fs_cfg --config
pcs -f fs_cfg constraint colocation add rc-local with virtual_ip INFINITY
pcs -f fs_cfg constraint order docker then rc-local
pcs cluster cib-push fs_cfg --config
pcs resource update rc-local op stop timeout=120s
pcs resource update rc-local op start timeout=120s
pcs resource update rc-local op restart timeout=120s


echo -e "*** Done Step 19 ***"
echo -e "19"	> step.txt



create_lsyncd_service:
echo -e "************************************************************"
echo -e "*             Create lsyncd Service in Server 1            *"
echo -e "************************************************************"

pcs resource create lsyncd service:lsyncd.service op monitor interval=30s
pcs cluster cib fs_cfg
pcs cluster cib-push fs_cfg --config
pcs -f fs_cfg constraint colocation add lsyncd with virtual_ip INFINITY
pcs -f fs_cfg constraint order rc-local then lsyncd
pcs cluster cib-push fs_cfg --config


echo -e "*** Done Step 20 ***"
echo -e "20"	> step.txt

basebspbx_create_bascul:
echo -e "************************************************************"
echo -e "*         Creating BasebsPBX Cluster base Command         *"
echo -e "************************************************************"
cat > /usr/bin/basebs << EOF
#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 30-Sep-2022
# Change the status of the servers, the Master goes to Stanby and the Standby goes to Master.
#funtion for draw a progress bar
#You must pass as argument the amount of secconds that the progress bar will run
#progress-bar 10 --> it will generate a progress bar that will run per 10 seconds

set -e
progress-bar() {
        local duration=\${1}

        already_done() { for ((done=0; done<\$elapsed; done++)); do printf ">"; done }
        remaining() { for ((remain=\$elapsed; remain<\$duration; remain++)); do printf " "; done }
        percentage() { printf "| %s%%" \$(( ((\$elapsed)*100)/(\$duration)*100/100 )); }
        clean_line() { printf "\r"; }

        for (( elapsed=1; elapsed<=\$duration; elapsed++ )); do
                already_done; remaining; percentage
                sleep 1
                clean_line
        done
        clean_line
}

server_a=\`pcs status | awk 'NR==10 {print \$3}'\`
server_b=\`pcs status | awk 'NR==10 {print \$4}'\`
server_master=\`pcs status resources | awk 'NR==1 {print \$4}'\`

#Perform some validations
if [ "\${server_a}" = "" ] || [ "\${server_b}" = "" ]
then
    echo -e "\e[41m There are problems with high availability, please check with the command *pcs status* (we recommend applying the command *pcs cluster unstandby* in both servers) \e[0m"
    exit;
fi

if [[ "\${server_master}" = "\${server_a}" ]]; then
        host_master=\$server_a
        host_standby=\$server_b
else
        host_master=\$server_b
        host_standby=\$server_a
fi

arg=\$1
if [ "\$arg" = 'yes' ] ;then
	perform_bascul='yes'
fi

# Print a warning message and ask to the user if he wants to continue
echo -e "************************************************************"
echo -e "*     Change the roles of servers in high availability     *"
echo -e "*\e[41m WARNING-WARNING-WARNING-WARNING-WARNING-WARNING-WARNING  \e[0m*"
echo -e "*All calls in progress will be lost and the system will be *"
echo -e "*     be in an unavailable state for a few seconds.        *"
echo -e "************************************************************"

#Perform a loop until the users confirm if wants to proceed or not
while [[ \$perform_bascul != yes && \$perform_bascul != no ]]; do
        read -p "Are you sure to switch from \$host_master to \$host_standby? (yes,no) > " perform_bascul
done

if [[ "\${perform_bascul}" = "yes" ]]; then
        #Unstandby both nodes
        pcs cluster unstandby \$host_master
        pcs cluster unstandby \$host_standby

        #Do a loop per resource
        pcs status resources | grep "^s.*s(.*):s.*" | awk '{print \$1}' | while read -r resource ; do
                #Skip moving the virutal_ip resource, it will be moved at the end
                if [[ "\${resource}" != "virtual_ip" ]]; then
                        echo "Moving \${resource} from \${host_master} to \${host_standby}"
                        pcs resource move ${resource} \${host_standby}
                fi
        done

        sleep 5 && pcs cluster standby \$host_master & #Standby current Master node after five seconds
        sleep 20 && pcs cluster unstandby \$host_master & #Automatically Unstandby current Master node after$

        #Move the Virtual IP resource to standby node
        echo "Moving virutal_ip from \${host_master} to \${host_standby}"
        pcs resource move virtual_ip \${host_standby}

        #End the script
        echo "Becoming \${host_standby} to Master"
        progress-bar 10
        echo "Done"
else
        echo "Nothing to do, bye, bye"
fi

sleep 5
role
EOF
chmod +x /usr/bin/basebs
scp /usr/bin/basebs root@$ip_standby:/usr/bin/basebs
ssh root@$ip_standby 'chmod +x /usr/bin/basebs'
echo -e "*** Done Step 21 ***"
echo -e "21"	> step.txt

basebspbx_create_role:
echo -e "************************************************************"
echo -e "*         Creating BasebsPBX Cluster role Command           *"
echo -e "************************************************************"
cat > /usr/bin/role << EOF
#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 30-Sep-2022
# Show the Role of Server.
#Bash Colour Codes
green="\033[00;32m"
txtrst="\033[00;0m"
if [ -f /etc/redhat-release ]; then
        linux_ver=\`cat /etc/redhat-release\`
        basebspbx_ver=\`rpm -qi basebspbx |awk -F: '/^Version/ {print \$2}'\`
        basebspbx_release=\`rpm -qi basebspbx |awk -F: '/^Release/ {print \$2}'\`
elif [ -f /etc/debian_version ]; then
        linux_ver="Debian "\`cat /etc/debian_version\`
        basebspbx_ver=\`dpkg -l basebspbx |awk '/ombutel/ {print \$3}'\`
else
        linux_ver=""
        basebspbx_ver=""
        basebspbx_release=""
fi
bpbx_version="KietCT_HA_Ver1"
server_master=\`pcs status resources | awk 'NR==1 {print \$4}'\`
host=\`hostname\`
if [[ "\${server_master}" = "\${host}" ]]; then
        server_mode="Master"
else
		server_mode="Standby"
fi
logo='
 ____                 ____ ____    ____  ______  __
| __ )  __ _ ___  ___| __ ) ___|  |  _ \| __ ) \/ /	
|  _ \ / _,  / __|/ _ \  _ \___ \  | |_) |  _ \\  /	
| |_) | (_| \__ \  __/ |_) |__) | |  __/| |_) /  \	
|____/ \__,_|___/\___|____/____/  |_|   |____/_/\_\	 
'
echo -e "
\${green}
\${logo}
\${txtrst}
 Role           : \$server_mode
 Version        : \${bpbx_version//[[:space:]]}
 Linux Version  : \${linux_ver}
 Welcome to     : \`hostname\`
 Uptime         : \`uptime | grep -ohe 'up .*' | sed 's/up //g' | awk -F "," '{print \$1}'\`
 Load           : \`uptime | grep -ohe 'load average[s:][: ].*' | awk '{ print "Last Minute: " \$3" Last 5 Minutes: "\$4" Last 15 Minutes: "\$5 }'\`
 Users          : \`uptime | grep -ohe '[0-9.*] user[s,]'\`
 IP Address     : \${green}\`ip addr | sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p' | xargs\`\${txtrst}
 Clock          :\`timedatectl | sed -n '/Local time/ s/^[ \t]*Local time:\(.*$\)/\1/p'\`
 NTP Sync.      :\`timedatectl |awk -F: '/NTP sync/ {print \$2}'\`
"
echo -e ""
echo -e "************************************************************"
echo -e "*                  Servers Status                          *"
echo -e "************************************************************"
echo -e "Master"
pcs status resources
echo -e ""
echo -e "Servers Status"
pcs cluster pcsd-status
EOF
chmod +x /usr/bin/role
scp /usr/bin/role root@$ip_standby:/usr/bin/role
ssh root@$ip_standby 'chmod +x /usr/bin/role'
echo -e "*** Done Step 22 ***"
echo -e "22"	> step.txt

create_welcome_message:
echo -e "************************************************************"
echo -e "*              Creating Welcome message                    *"
echo -e "************************************************************"
/bin/cp -rf /usr/bin/role /etc/profile.d/basebswelcome.sh
chmod 755 /etc/profile.d/basebswelcome.sh
echo -e "*** Done ***"
scp /etc/profile.d/basebswelcome.sh root@$ip_standby:/etc/profile.d/basebswelcome.sh
ssh root@$ip_standby "chmod 755 /etc/profile.d/basebswelcome.sh"
echo -e "*** Done Step 23 END ***"
echo -e "23"	> step.txt
wget https://raw.githubusercontent.com/kietcaodev/siprec/main/mariadbfix
sleep 5
yes | cp -fr mariadbfix /usr/bin/mariadbfix
yes | cp -fr config.txt /usr/bin/config.txt
chmod +x /usr/bin/mariadbfix

basebspbx_cluster_ok:
echo -e "************************************************************"
echo -e "*                BasebsPBX Cluster OK                       *"
echo -e "*    Don't worry if you still see the status in Stop       *"
echo -e "*  sometimes you have to wait about 30 seconds for it to   *"
echo -e "*                 restart completely                       *"
echo -e "*         after 30 seconds run the command: role           *"
echo -e "************************************************************"
sleep 20
role

