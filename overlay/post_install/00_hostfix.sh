#/bin/sh
OLDHOST=`sysrc -n hostname`
HOST=`echo ${OLDHOST} | sed "s/_//"`
sysrc hostname=${HOST}

sed -i .bak "s/HOST/${HOST}/g" /etc/hosts
