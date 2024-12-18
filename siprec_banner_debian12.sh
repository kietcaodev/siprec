cat > /etc/profile.d/basebswelcome.sh << EOF
#!/bin/bash
# This code is the property of BasebsPBX LLC Company
# License: Proprietary
# Date: 01-Nov-2024
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
██████╗  █████╗ ███████╗███████╗██████╗ ███████╗    ███████╗██╗██████╗ ██████╗ ███████╗ ██████╗
██╔══██╗██╔══██╗██╔════╝██╔════╝██╔══██╗██╔════╝    ██╔════╝██║██╔══██╗██╔══██╗██╔════╝██╔════╝
██████╔╝███████║███████╗█████╗  ██████╔╝███████╗    ███████╗██║██████╔╝██████╔╝█████╗  ██║     
██╔══██╗██╔══██║╚════██║██╔══╝  ██╔══██╗╚════██║    ╚════██║██║██╔═══╝ ██╔══██╗██╔══╝  ██║     
██████╔╝██║  ██║███████║███████╗██████╔╝███████║    ███████║██║██║     ██║  ██║███████╗╚██████╗
╚═════╝ ╚═╝  ╚═╝╚══════╝╚══════╝╚═════╝ ╚══════╝    ╚══════╝╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝
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
 NTP Sync       :\`timedatectl |awk -F: '/System clock synchronized/ {print \$2}'\`
"
EOF
chmod 755 /etc/profile.d/basebswelcome.sh
