#!/bin/sh

for SCRIPT in  `ls /tmp/post_install/*.sh`
do 
echo "~~~~~~~~~~ ${SCRIPT} ~~~~~~~~~~"
sh -c "${SCRIPT}"
done

