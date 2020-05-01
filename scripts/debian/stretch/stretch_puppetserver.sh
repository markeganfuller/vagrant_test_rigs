#!/bin/bash

wget https://apt.puppetlabs.com/puppet-release-stretch.deb
dpkg -i puppet-release-stretch.deb

apt-get update
apt-get install puppetserver puppet-agent -y

sed -i 's/-Xms2g -Xmx2g/-Xms512m -Xmx512m/' /etc/default/puppetserver
