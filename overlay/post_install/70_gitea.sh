#!/bin/sh

mkdir -p /var/db/gitea
mkdir -p /var/log/gitea
chown -R git:git /var/db/gitea
chown -R git:git /var/log/gitea

CFG=/root/plugin_config
# Save the config values
export LC_ALL=C
sysrc -f ${CFG} gitea_lfs_jwt_secret="`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 64`"
sysrc -f ${CFG} gitea_secret_key="`head /dev/urandom | tr -dc A-Za-z0-9 | head -c 64`"
sysrc -f ${CFG} gitea_internal_token="`openssl rand -base64 64 | tr -d '\n'`"

LFS_JWT_SECRET=`sysrc -f ${CFG} -n gitea_lfs_jwt_secret`
SECRET_KEY=`sysrc -f ${CFG} -n gitea_secret_key`
INTERNAL_TOKEN=`sysrc -f ${CFG} -n gitea_internal_token`

DB=`sysrc -f ${CFG} -n mysql_db`
USER=`sysrc -f ${CFG} -n mysql_user`
PASS=`sysrc -f ${CFG} -n mysql_pass`

HOST=`sysrc -n hostname`

CFG=/usr/local/etc/gitea/conf/app.ini
cp ${CFG}.sample ${CFG}
# Setup Gitea database
sed -i '' -e "s/DB_TYPE  = sqlite3/DB_TYPE  = mysql/" ${CFG}
sed -i '' -e "s/HOST     = 127.0.0.1:3306/HOST     = \/tmp\/mysql.sock/" ${CFG}
sed -i '' -e "s/PATH     = \/var\/db\/gitea\/gitea.db/PATH     =/" ${CFG}
sed -i '' -e "s/USER     = root/USER     = ${USER}/" ${CFG}
sed -i '' -e "s/PASSWD   = /PASSWD   = ${PASS}/" ${CFG}
# Setup Gitea server
sed -i '' -e 's/^\[server\]$/[server]\
LFS_START_SERVER = true\
LFS_CONTENT_PATH = \/var\/db\/gitea\/data\/lfs\
LFS_JWT_SECRET = LFS_JWT_SECRET_PLACEHOLDER\
PROTOCOL     = unix/' ${CFG}
sed -i '' -e "s/LFS_JWT_SECRET_PLACEHOLDER/${LFS_JWT_SECRET}/" ${CFG}
sed -i '' -e "s/HTTP_ADDR    = 127.0.0.1/HTTP_ADDR    = \/tmp\/gitea.sock/" ${CFG}
sed -i '' -e "s/HTTP_PORT    = 3000/HTTP_PORT    = /" ${CFG}
sed -i '' -e "s/ROOT_URL     = http:\/\/localhost:3000/ROOT_URL     = https:\/\/%\(DOMAIN\)s/" ${CFG}
# Change the secret.
sed -i '' -e "s/SECRET_KEY   = ChangeMeBeforeRunning/SECRET_KEY   = ${SECRET_KEY}/" ${CFG}
# Disable stuff.s
sed -i '' -e "s/DISABLE_GRAVATAR        = false/DISABLE_GRAVATAR        = true/" ${CFG}
sed -i '' -e "s/ENABLE_CAPTCHA         = true/ENABLE_CAPTCHA         = false/" ${CFG}
sed -i '' -e "s/DISABLE_HTTP_GIT = false/DISABLE_HTTP_GIT = true/" ${CFG}
# Configure session backend.
sed -i '' -e "s/PROVIDER = file/PROVIDER = redis/" ${CFG}
sed -i '' -e "s/PROVIDER_CONFIG = \/var\/db\/gitea\/data\/sessions/PROVIDER_CONFIG = network=unix,addr=\/tmp\/redis.sock,db=0,pool_size=100,idle_timeout=180/" ${CFG}
# Configure cache backend.
cat <<EOF>> ${CFG}
[cache]
ADAPTER = redis
HOST = network=unix,addr=/tmp/redis.sock,db=1,pool_size=100,idle_timeout=180

[attachment]
ENABLED = true
PATH = /var/db/gitea/data/attachments
EOF
# Compare the files. Eyeball the results for a sanity check.

diff ${CFG} ${CFG}.sample

service start gitea
