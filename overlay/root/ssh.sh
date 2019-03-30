#!/bin/csh

## SSH
#Config
setenv CFG /etc/ssh/sshd_config

cat <<EOF> ${CFG}
AllowUsers git
ChallengeResponseAuthentication no
PasswordAuthentication no
UsePAM no
EOF

# Enable the service
echo "- Enable SSH" 
sysrc -f /etc/rc.conf sshd_enable="YES"

# Start the service
echo "- Start SSH" 
service sshd start
