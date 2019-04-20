#!/bin/sh

# Enable the service & disable networking.
echo "- Enable MySQL"
sysrc -f /etc/rc.conf mysql_enable="YES"
sysrc -f /etc/rc.conf mysql_args="--skip-networking"

# Start the service
echo "- Start MySQL" >> ${LOG}
service mysql-server start

USER="gitea"
DB="gitea"

# Save the config values
echo "$DB" > /root/dbname
echo "$USER" > /root/dbuser
export LC_ALL=C
cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 16 | head -n 1 > /root/dbpassword
PASS=`cat /root/dbpassword`

echo "Database User: $USER"
echo "Database Password: $PASS"

# Configure mysql
mysql -u root -p`tail -n1 /root/.mysql_secret` --socket=/tmp/mysql.sock --connect-expired-password <<-EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${PASS}';
CREATE DATABASE \`${DB}\` DEFAULT CHARACTER SET 'utf8mb4' COLLATE 'utf8mb4_unicode_ci';
CREATE USER '${USER}'@'localhost' IDENTIFIED BY '${PASS}';
GRANT ALL PRIVILEGES ON ${DB}.* TO '${USER}'@'localhost';
FLUSH PRIVILEGES;
EOF

