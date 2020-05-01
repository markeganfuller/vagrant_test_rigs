#!/bin/bash

apt-get update
apt-get install -y nginx

# Remove stock stuff
rm /var/www/html/*
rm /etc/nginx/sites-enabled/*

# Add basic nginx conf
cat << EOF > /etc/nginx/sites-enabled/test
upstream webapp {
    server 127.0.0.1:8888;
}

server {
	listen 80;
	listen [::]:80;

	server_name _;

	root /var/www/html;

	location /notapp {
		try_files $uri $uri/ =404;
	}

	location /app {
		proxy_pass http://webapp;
	}
}

EOF

# Python 'App' Server
cat << EOF > /etc/systemd/system/webapp.service
[Unit]
Description=Fake webapp
After=network.target

[Service]
WorkingDirectory=/srv
ExecStart=/usr/bin/python3 -m http.server -b 127.0.0.1 8888
EOF

## App content
mkdir /srv/app
echo "This is the app" > /srv/app/index.html

# Non app content
echo "This is not the app" > /var/www/html/index.html


systemctl daemon-reload
systemctl restart webapp
systemctl restart nginx
