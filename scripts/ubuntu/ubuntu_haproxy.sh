#!/bin/bash

apt-get update
apt-get install -y haproxy

cat << EOF > /etc/haproxy/haproxy.cfg
defaults
  mode http
  timeout client 10s
  timeout connect 5s
  timeout server 10s
  timeout http-request 10s
  errorfile 503 /srv/503.html

frontend stats
    bind :::8404
    stats enable
    stats uri /stats
    stats refresh 30s
    stats admin if TRUE  # Force admin, don't use in production

frontend myfrontend
  bind :::80 v4v6
  default_backend app

backend app
EOF

cat << EOF > /srv/503.html
HTTP/1.0 503 Service Unavailable
Cache-Control: no-cache
Connection: close
Content-Type: text/html

<html>
<head>
</head>
<body>
<h1>Service currently down for maintenance</h1>
</body>
</html>
EOF

for i in 1 2; do
    port=$((8887 + i))
    echo "Setting up app ${i} on port ${port}"
    # Python 'App' Server
    cat << EOF > /etc/systemd/system/app${i}.service
[Unit]
Description=Fake web app ${i}
After=network.target

[Service]
WorkingDirectory=/srv/app${i}
ExecStart=/usr/bin/python3 -m http.server -b 127.0.0.1 ${port}
EOF

    mkdir "/srv/app${i}"
    echo "This is app ${i}" > "/srv/app${i}/index.html"
    echo "server server${i} 127.0.0.1:${port}" >> /etc/haproxy/haproxy.cfg

    systemctl daemon-reload
    systemctl restart "app${i}"
    systemctl restart haproxy
done
