#!/bin/sh

echo "- Enable Redis"
sysrc -f /etc/rc.conf redis_enable="YES"

# Start the service
echo "- Start Redis"
service redis start

