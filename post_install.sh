#!/bin/sh

# "Logging"
echo "---- Beginning Gitea Plugin Jail Install ---"

## Redis
sh /root/redis.sh

## MySQL
sh /root/mysql.sh

## SSH
sh /root/ssh.sh

## Gitea
sh /root/gitea.sh

## F5 NGINX(Tm)
sh /root/nginx.sh
