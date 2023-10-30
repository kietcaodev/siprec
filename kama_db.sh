#!/bin/bash
expect -f - <<-EOF
  set timeout 10
  spawn sudo kamdbctl create
  expect "MySQL password for root:"
  send -- "Basebs2022\r"
  expect "Create the presence related tables?"
  send -- "y\r"
  expect "rtpproxy rtpengine secfilter?"
  send -- "y\r"
  expect "uid_uri_db?"
  send -- "y\r"				
  expect eof
EOF
