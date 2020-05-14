#!/bin/bash

if lsb_release -a 2>&1 | grep wheezy -q; then
    # Fix wheezy repos
    # First we need to use archive
    cat << EOF > /etc/apt/sources.list
deb http://archive.debian.org/debian wheezy main non-free contrib
deb-src http://archive.debian.org/debian wheezy main non-free contrib
EOF
    # Clean up any additional repos
    rm /etc/apt/sources.list.d/*
    # We also need to ignore signing as the key has expired
    echo 'APT::Get::AllowUnauthenticated "true";' >> /etc/apt/apt.conf.d/99-allow-unauth
fi

apt-get update
apt-get install -y net-tools nmap tcpdump vim apt-transport-https ca-certificates curl gnupg2 software-properties-common tree
