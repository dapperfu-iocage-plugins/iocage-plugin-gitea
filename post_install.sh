#!/bin/sh

# "Logging"
echo "---- Beginning Gitea Plugin Jail Install ---"

## Redis
sh redis.sh

## MySQL
sh mysql.sh

## SSH
sh ssh.sh

## Gitea
sh gitea.sh

## F5 NGINX(Tm)
sh nginx.sh
