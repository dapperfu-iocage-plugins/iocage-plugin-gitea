#!/bin/sh

sysrc mdnsd_enable=yes
sysrc mdnsd_flags="epair0b"

service mdnsd start
