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

frontend frontend
  bind :::80 v4v6
  default_backend app1
  use_backend app2 if  { path /app2 } || { path_beg /app2/ }
  use_backend app3 if  { path /app3 } || { path_beg /app3/ }

backend app1
  server server1 127.0.0.1:8888
  server server2 127.0.0.1:8889

# Testing rate limiting
backend app2
  # Entries removed after 30s of inactivity
  # 10s is the sliding window size
  stick-table type ipv6 size 100k expire 30s store http_req_rate(10s)
  http-request track-sc0 src
  # 20 is the max requests in the sliding window
  http-request deny deny_status 429 if { sc_http_req_rate(0) gt 20 }

  server server1 127.0.0.1:8888
  server server2 127.0.0.1:8889

backend app3
  # Entries removed after 30s of inactivity
  # 10s is the sliding window size
  stick-table type ipv6 size 100k expire 30s store http_req_rate(10s)
  http-request track-sc0 src
  # 20 is the max requests in the sliding window
  http-request deny deny_status 429 if { sc_http_req_rate(0) gt 20 }

  server server1 127.0.0.1:8888
  server server2 127.0.0.1:8889

EOF

# Test custom 503 page
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
    echo "Setting up backend ${i} on port ${port}"
    # Python 'App' Server
    cat << EOF > /etc/systemd/system/backend${i}.service
[Unit]
Description=Fake web app ${i}
After=network.target

[Service]
WorkingDirectory=/srv/backend${i}
ExecStart=/usr/bin/python3 -m http.server -b 127.0.0.1 ${port}
EOF

    mkdir -p "/srv/backend${i}/app2"
    mkdir "/srv/backend${i}/app3"
    echo "This is app1 on backend ${i}" > "/srv/backend${i}/index.html"
    echo "This is app2 on backend ${i}" > "/srv/backend${i}/app2/index.html"
    echo "This is app3 on backend ${i}" > "/srv/backend${i}/app3/index.html"

    systemctl daemon-reload
    systemctl restart "backend${i}"
done

systemctl restart haproxy
