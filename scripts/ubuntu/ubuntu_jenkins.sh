#!/bin/bash

cat > /etc/apt/sources.list.d/jenkins.list <<EOF
deb https://pkg.jenkins.io/debian-stable binary/
EOF

wget -qO - https://pkg.jenkins.io/debian-stable/jenkins.io.key | apt-key add -

apt-get update

apt-get install openjdk-11-jdk -y
apt-get install jenkins=2.361.1 -y
