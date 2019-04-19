#!/bin/sh

CFG=/usr/local/etc/redis.conf
cp ${CFG}.sample ${CFG}
: Enable unix socket.
sed -i .bak -e 's/# unixsocket/unixsocket/g' ${CFG}
: Change permissions so git user can use it
sed -i .bak -e 's/unixsocketperm 700/unixsocketperm 777/g' ${CFG}
: Disable TCP.
sed -i .bak -e 's/^port 6379/port 0/' ${CFG}
diff ${CFG} ${CFG}.sample

echo "- Enable Redis"
sysrc -f /etc/rc.conf redis_enable="YES"

# Start the service
echo "- Start Redis"
service redis start

