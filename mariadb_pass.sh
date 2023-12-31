#!/bin/bash
sudo yum install -y expect
sudo yum -y install mariadb-server
sudo systemctl enable --now mariadb
sudo systemctl start mariadb
sleep 5
expect -f - <<-EOF
  set timeout 10
  spawn mysql_secure_installation
  expect "Enter current password for root (enter for none):"
  send -- "\r"
  expect "Set root password?"
  send -- "y\r"
  expect "New password:"
  send -- "mariadb_pass\r"
  expect "Re-enter new password:"
  send -- "mariadb_pass\r"
  expect "Remove anonymous users?"
  send -- "y\r"
  expect "Disallow root login remotely?"
  send -- "y\r"
  expect "Remove test database and access to it?"
  send -- "y\r"
  expect "Reload privilege tables now?"
  send -- "y\r"
  expect eof
EOF
