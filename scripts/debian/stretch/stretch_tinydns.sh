#!/bin/bash

apt-get update
apt-get install -y make gcc daemontools ucspi-tcp

# Build Tinydns
wget http://cr.yp.to/djbdns/djbdns-1.05.tar.gz

gunzip djbdns-1.05.tar
tar -xf djbdns-1.05.tar
cd djbdns-1.05 || exit 1

echo gcc -O2 -include /usr/include/errno.h > conf-cc
make

make setup check

# Setup users and configs
useradd -U -M -r -d /etc/tinydns tinydns

tinydns-conf tinydns tinydns /etc/tinydns 127.0.0.1

# TODO Config of service.
