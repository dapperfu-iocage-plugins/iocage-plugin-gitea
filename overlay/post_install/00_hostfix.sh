#/bin/sh
OLDHOST=`sysrc hostname | cut -f2 -d" "`
HOST=`echo ${OLDHOST} | sed "s/_//"`
sysrc hostname=${HOST}

sed -i .bak "s/HOST/${HOST}/g" /etc/hosts
