#!/bin/sh

mkdir -p /var/db/gitea
mkdir -p /var/log/gitea
chown -R git:git /var/db/gitea
chown -R git:git /var/log/gitea

CFG=/root/plugin_config
# Save the config values
export LC_ALL=C
sysrc -f ${CFG} gitea_jwt_secret="`/usr/local/sbin/gitea generate secret JWT_SECRET`"
sysrc -f ${CFG} gitea_lfs_jwt_secret="`/usr/local/sbin/gitea generate secret LFS_JWT_SECRET`"
sysrc -f ${CFG} gitea_secret_key="`/usr/local/sbin/gitea generate secret SECRET_KEY`"
sysrc -f ${CFG} gitea_internal_token="`/usr/local/sbin/gitea generate secret INTERNAL_TOKEN`"

JWT_SECRET=`sysrc -f ${CFG} -n gitea_jwt_secret`
LFS_JWT_SECRET=`sysrc -f ${CFG} -n gitea_lfs_jwt_secret`
SECRET_KEY=`sysrc -f ${CFG} -n gitea_secret_key`
INTERNAL_TOKEN=`sysrc -f ${CFG} -n gitea_internal_token`

DB=`sysrc -f ${CFG} -n mysql_db`
USER=`sysrc -f ${CFG} -n mysql_user`
PASS=`sysrc -f ${CFG} -n mysql_pass`

HOST=`sysrc -n hostname`

CFG=/usr/local/etc/gitea/conf/app.ini
cp ${CFG}.plugin ${CFG}

sed -i '' -e "s/__PASSWD__/${PASS}/" ${CFG}

sed -i '' -e "s/__JWT_SECRET__/${JWT_SECRET}/" ${CFG}
sed -i '' -e "s/__LFS_JWT_SECRET__/${LFS_JWT_SECRET}/" ${CFG}
sed -i '' -e "s/__SECRET_KEY__/${SECRET_KEY}/" ${CFG}
sed -i '' -e "s/__HOST__/${HOST}/g" ${CFG}

service gitea start
