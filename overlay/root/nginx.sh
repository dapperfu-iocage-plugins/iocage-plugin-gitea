#!/bin/sh

HOST=`tail -n1 /etc/hosts | cut -f2`

openssl req -nodes -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt -subj "/C=GB/ST=London/L=London/O=FreeNAS/OU=FreeNAS/CN=${HOST}.local"

CFG=/usr/local/etc/nginx/nginx.conf
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
