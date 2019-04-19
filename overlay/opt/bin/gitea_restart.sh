#!/bin/sh

service nginx stop
service gitea stop
service mysql-server stop
service redis stop


service redis start
service mysql-server start
service gitea start
service nginx start
