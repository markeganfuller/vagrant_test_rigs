#!/bin/bash

rpm -Uvh http://rpm.repo.onapp.com/repo/onapp-repo-6.0.noarch.rpm
yum -y install onapp-cp-install

# /onapp/onapp-cp-install/onapp-cp-install.sh [-i <ip address>]
# webinterface admin/changeme
# License needs to be input
