#!/bin/sh

service nginx stop
service gitea stop
service mysql stop
service redis stop


service redis start
service mysql start
service gitea start
service nginx start
