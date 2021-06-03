#!/bin/bash

apt-get update
apt-get install -y make gcc daemontools ucspi-tcp dnsutils

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

cat > /etc/systemd/system/tinydns.service <<EOF
[Unit]
After=local-fs.target network.target

[Service]
User=root
WorkingDirectory=/etc/tinydns
Environment="IP=127.0.01"
Environment="ROOT=/etc/tinydns/root"
Environment="UID=root"
Environment="GROUP=root"
ExecStart=/etc/tinydns/run
KillMode=process
Restart=always

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/tinydns/root/data <<EOF
.example.com:127.0.0.1::300
=google.example.com:8.8.8.8:300
EOF
# TODO Config axfrdns
