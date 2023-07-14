#!/bin/bash

apt-get update
apt-get install -y apache2
a2enmod ssl
a2ensite default-ssl.conf

systemctl restart apache2
