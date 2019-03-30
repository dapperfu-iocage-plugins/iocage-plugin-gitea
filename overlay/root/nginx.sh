#!/bin/sh

HOST=`tail -n1 /etc/hosts | cut -f2`

# Generate SSL Certs
openssl req -x509 -nodes -days 3650 -newkey rsa:2048 -keyout /etc/ssl/nginx-selfsigned.key -out /etc/ssl/nginx-selfsigned.crt -subj "/C=GB/ST=London/L=London/O=FreeNAS Gitea Jail/OU=FreeNAS Gitea Jail/CN=${HOST}.local"

sysrc nginx_enable=yes
service nginx start
