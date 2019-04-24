#!/bin/sh

cat /dev/urandom | tr -dc 'a-zA-Z0-9_' | fold -w 43 | head -n 1 > /root/LFS_JWT_SECRET
cat /dev/urandom | tr -dc 'a-zA-Z0-9_' | fold -w 43 | head -n 1 > /root/SECRET_KEY

LFS_JWT_SECRET=`cat /root/LFS_JWT_SECRET`
SECRET_KEY=`cat /root/SECRET_KEY`
DB=`cat /root/dbname`
USER=`cat /root/dbuser`
PASS=`cat /root/dbpassword`

HOST=`tail -n1 /etc/hosts | cut -f2`

CFG=/usr/local/etc/gitea/conf/app.ini
cp ${CFG}.sample ${CFG}

: Setup Gitea database
sed -i .bak -e "s/DB_TYPE  = sqlite3/DB_TYPE  = mysql/" ${CFG}
sed -i .bak -e "s/HOST     = 127.0.0.1:3306/HOST     = \/tmp\/mysql.sock/" ${CFG}
sed -i .bak -e "s/PATH     = \/var\/db\/gitea\/gitea.db/PATH     =/" ${CFG}
sed -i .bak -e "s/USER     = root/USER     = ${USER}/ "${CFG}
sed -i .bak -e "s/PASSWD   = ${PASS}/" ${CFG}
: Setup Gitea server
sed -i .bak -e 's/^\[server\]$/[server]\\
LFS_START_SERVER = true \\
LFS_CONTENT_PATH = \/var\/db\/gitea\/data\/lfs \\
LFS_JWT_SECRET = LFS_JWT_SECRET_PLACEHOLDER \\
PROTOCOL     = unix/' ${CFG}
sed -i .bak -e "s/LFS_JWT_SECRET_PLACEHOLDER/${LFS_JWT_SECRET}/" ${CFG}
sed -i .bak -e "s/HTTP_ADDR    = 127.0.0.1/HTTP_ADDR    = \/tmp\/gitea.sock/" ${CFG}
sed -i .bak -e "s/HTTP_PORT    = 3000/HTTP_PORT    = /" ${CFG}
sed -i .bak -e "s/ROOT_URL     = http:\/\/localhost:3000/ROOT_URL     = https:\/\/%\(DOMAIN\)s/" ${CFG}
: Change the secret.
sed -i .bak -e "s/SECRET_KEY   = ChangeMeBeforeRunning/SECRET_KEY   = ${SECRET_KEY}/" ${CFG}
: Disable stuff.
sed -i .bak -e "s/DISABLE_GRAVATAR        = false/DISABLE_GRAVATAR        = true/" ${CFG}
sed -i .bak -e "s/ENABLE_CAPTCHA         = true/ENABLE_CAPTCHA         = false/" ${CFG}
sed -i .bak -e "s/DISABLE_HTTP_GIT = false/DISABLE_HTTP_GIT = true/" ${CFG}
: Configure session backend.
sed -i .bak -e "s/PROVIDER = file/PROVIDER = redis/" ${CFG}
sed -i .bak -e "s/PROVIDER_CONFIG = \/var\/db\/gitea\/data\/sessions/PROVIDER_CONFIG = network=unix,addr=\/tmp\/redis.sock,db=0,pool_size=100,idle_timeout=180/" ${CFG}
: Configure cache backend.
cat <<EOF>> ${CFG}
[cache]
ADAPTER = redis
HOST = network=unix,addr=/tmp/redis.sock,db=1,pool_size=100,idle_timeout=180

[attachment]
ENABLED = true
PATH = /var/db/gitea/data/attachments
EOF
: Compare the files. Eyeball the results for a sanity check.

diff ${CFG} ${CFG}.sample#

sysrc gitea_enable=yes
service start gitea
