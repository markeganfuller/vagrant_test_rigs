#!/bin/bash

yum update
yum install -y httpd mod_ssl

systemctl daemon-reload
systemctl restart httpd
