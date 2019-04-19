#!/bin/sh

for SCRIPT in  `ls /tmp/post_install/*.sh`
do 
echo "~~~~~~~~~~ ${SCRIPT} ~~~~~~~~~~"
sh -c "${SCRIPT}"
done

rm -rf /tmp/post_install
rm -rf ${0}
