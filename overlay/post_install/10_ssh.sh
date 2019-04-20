#!/bin/sh

# Enable the service
echo "- Enable SSH" 
sysrc -f /etc/rc.conf sshd_enable="YES"

# Start the service
echo "- Start SSH" 
service sshd start
