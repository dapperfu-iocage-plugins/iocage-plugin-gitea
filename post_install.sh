#!/bin/sh
# To disable any post_install scripts, change suffix from .sh

echo '##### Plugin Configuration #####' > /root/plugin_config

for SCRIPT in  `ls /post_install/*.sh`
do                                     # for SCRIPT {
echo "~~~~~~~~~~ ${SCRIPT} ~~~~~~~~~~" # Echo Das Script
sh -c "${SCRIPT}"                      # Run das script.
done                                   # }
cat /root/plugin_config
