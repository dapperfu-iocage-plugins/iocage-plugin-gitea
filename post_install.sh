#!/bin/sh

setenv LOG=/root/PLUGIN_INFO

# "Logging"
echo "---- Beginning Gitea Plugin Jail Install ---" > ${LOG}

## Redis
# Config
setenv CFG /usr/local/etc/redis.conf
cp ${CFG}.sample ${CFG}
: Enable unix socket.
sed -i .bak -e 's/# unixsocket/unixsocket/g' ${CFG}
: Change permissions so git user can use it
sed -i .bak -e 's/unixsocketperm 700/unixsocketperm 777/g' ${CFG}
: Disable TCP.
sed -i .bak -e 's/^port 6379/port 0/' ${CFG}

echo "- Redis Config Diff" >> ${LOG} 
diff ${CFG} ${CFG}.sample >> ${LOG} 

# Enable the service
echo "- Enable Redis" >> ${LOG}
sysrc -f /etc/rc.conf redis_enable="YES"

# Start the service
echo "- Start Redis" >> ${LOG}
service redis start

## MySQL
# Config
setenv CFG /usr/local/etc/mysql/my.cnf
cp ${CFG}.sample ${CFG}
sed -i .bak -e 's/^\[mysqld\]$/[mysqld]\\
skip-networking/' ${CFG}

echo "- MySQL Config Diff" >> ${LOG}
diff ${CFG} ${CFG}.sample >> ${LOG}


# Enable the service & disable networking.
echo "- Enable MySQL" >> ${LOG}
sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf mysql_args="--skip-networking"

# Start the service
echo "- Start MySQL" >> ${LOG}
service mysql-server start

## SSH
#Config
setenv CFG /etc/ssh/sshd_config

cat <<EOF> ${CFG}
AllowUsers git
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no 
EOF

# Enable the service
echo "- Enable SSH" >> ${LOG}
sysrc -f /etc/rc.conf sshd_enable="YES"

# Start the service
echo "- Start SSH" >> ${LOG}
service sshd start

## Gitea
# Config
: Generate some random secret strings.
setenv LFS_JWT_SECRET `cat /dev/urandom | tr -dc 'a-zA-Z0-9_' | fold -w 43 | head -n 1`
setenv SECRET_KEY `cat /dev/urandom | tr -dc 'a-zA-Z0-9_' | fold -w 43 | head -n 1`

setenv CFG /usr/local/etc/gitea/conf/app.ini
cp ${CFG}.sample ${CFG}

: Setup Gitea database
sed -i .bak -e "s/DB_TYPE  = sqlite3/DB_TYPE  = mysql/" ${CFG}
sed -i .bak -e "s/HOST     = 127.0.0.1:3306/HOST     = \/tmp\/mysql.sock/" ${CFG}
sed -i .bak -e "s/PATH     = \/var\/db\/gitea\/gitea.db/PATH     =/" ${CFG}
: Setup Gitea server
sed -i .bak -e 's/^\[server\]$/[server]\\
LFS_START_SERVER = true \\
LFS_CONTENT_PATH = \/var\/db\/gitea\/data\/lfs \\
LFS_JWT_SECRET = LFS_JWT_SECRET_PLACEHOLDER \\
PROTOCOL     = unix/' ${CFG}
sed -i .bak -e "s/LFS_JWT_SECRET_PLACEHOLDER/${LFS_JWT_SECRET}/" ${CFG}
sed -i .bak -e "s/HTTP_ADDR    = 127.0.0.1/HTTP_ADDR    = \/tmp\/gitea.sock/" ${CFG}
sed -i .bak -e "s/HTTP_PORT    = 3000/HTTP_PORT    = /" ${CFG}
sed -i .bak -e "s/ROOT_URL     = http:\/\/localhost:3000/ROOT_URL     = https:\/\/%\(DOMAIN\)s/" 
${CFG}
: Change the secret.
sed -i .bak -e "s/SECRET_KEY   = ChangeMeBeforeRunning/SECRET_KEY   = ${SECRET_KEY}/" ${CFG}
: Disable stuff.
sed -i .bak -e "s/DISABLE_GRAVATAR        = false/DISABLE_GRAVATAR        = true/" ${CFG}
sed -i .bak -e "s/ENABLE_CAPTCHA         = true/ENABLE_CAPTCHA         = false/" ${CFG}
sed -i .bak -e "s/DISABLE_HTTP_GIT = false/DISABLE_HTTP_GIT = true/" ${CFG}
: Configure session backend.
sed -i .bak -e "s/PROVIDER = file/PROVIDER = redis/" ${CFG}
sed -i .bak -e "s/PROVIDER_CONFIG = \/var\/db\/gitea\/data\/sessions/PROVIDER_CONFIG = 
network=unix,addr=\/tmp\/redis.sock,db=0,pool_size=100,idle_timeout=180/" ${CFG}
: Configure cache backend.
cat <<EOF>> ${CFG}
[cache]
ADAPTER = redis
HOST = network=unix,addr=/tmp/redis.sock,db=1,pool_size=100,idle_timeout=180

[attachment]
ENABLED = true
PATH = /var/db/gitea/data/attachments
EOF

echo "- Gitea Config Diff" >> ${LOG}
diff ${CFG} ${CFG}.sample >> /root/PLUGIN_INFO

## F5 NGINX(Tm)

openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out 
/etc/ssl/nginx-selfsigned.crt

setenv CFG /usr/local/etc/nginx/nginx.conf
rm ${CFG}

cat <<EOM > ${CFG}
worker_processes  1;

events {
    worker_connections  1024;
}

http {
    include       mime.types;
    default_type  application/octet-stream;
    sendfile        on;
    keepalive_timeout  65;

    server {
    	listen 80 default_server;
    	server_name _;
    	return 301 https://\$host\$request_uri;
    }

    server {
        listen 443 ssl default_server;
    	server_name _;
    	ssl_certificate /etc/ssl/nginx-selfsigned.crt;
        ssl_certificate_key /etc/ssl/nginx-selfsigned.key;
        location / {
            proxy_pass http://unix:/tmp/gitea.sock;
        }
    }
}
EOM

sysrc nginx_enable=yes
service nginx start
