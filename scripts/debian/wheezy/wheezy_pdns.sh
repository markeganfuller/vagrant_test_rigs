#!/bin/bash
echo "deb http://archive.debian.org/debian/ wheezy-backports main non-free contrib" > /etc/apt/sources.list.d/backports.list

apt-get update
apt-get install -y pdns-recursor=3.6.2-2+deb8u2~bpo70+1
