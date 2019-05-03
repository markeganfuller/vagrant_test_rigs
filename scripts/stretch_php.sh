#!/bin/bash

apt-get update
apt-get install -y apache2 libapache2-mod-php

systemctl restart apache2
