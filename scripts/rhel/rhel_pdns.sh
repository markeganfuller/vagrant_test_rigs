#!/bin/bash

NODE_1_IP=$1
NODE_2_IP=$2

yum install -y pdns pdns-backend-sqlite

echo "PRAGMA foreign_keys = 1;

CREATE TABLE domains (
  id                    INTEGER PRIMARY KEY,
  name                  VARCHAR(255) NOT NULL COLLATE NOCASE,
  master                VARCHAR(128) DEFAULT NULL,
  last_check            INTEGER DEFAULT NULL,
  type                  VARCHAR(6) NOT NULL,
  notified_serial       INTEGER DEFAULT NULL,
  account               VARCHAR(40) DEFAULT NULL
);

CREATE UNIQUE INDEX name_index ON domains(name);


CREATE TABLE records (
  id                    INTEGER PRIMARY KEY,
  domain_id             INTEGER DEFAULT NULL,
  name                  VARCHAR(255) DEFAULT NULL,
  type                  VARCHAR(10) DEFAULT NULL,
  content               VARCHAR(65535) DEFAULT NULL,
  ttl                   INTEGER DEFAULT NULL,
  prio                  INTEGER DEFAULT NULL,
  change_date           INTEGER DEFAULT NULL,
  disabled              BOOLEAN DEFAULT 0,
  ordername             VARCHAR(255),
  auth                  BOOL DEFAULT 1,
  FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX records_lookup_idx ON records(name, type);
CREATE INDEX records_lookup_id_idx ON records(domain_id, name, type);
CREATE INDEX records_order_idx ON records(domain_id, ordername);


CREATE TABLE supermasters (
  ip                    VARCHAR(64) NOT NULL,
  nameserver            VARCHAR(255) NOT NULL COLLATE NOCASE,
  account               VARCHAR(40) NOT NULL
);

CREATE UNIQUE INDEX ip_nameserver_pk ON supermasters(ip, nameserver);


CREATE TABLE comments (
  id                    INTEGER PRIMARY KEY,
  domain_id             INTEGER NOT NULL,
  name                  VARCHAR(255) NOT NULL,
  type                  VARCHAR(10) NOT NULL,
  modified_at           INT NOT NULL,
  account               VARCHAR(40) DEFAULT NULL,
  comment               VARCHAR(65535) NOT NULL,
  FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX comments_idx ON comments(domain_id, name, type);
CREATE INDEX comments_order_idx ON comments (domain_id, modified_at);


CREATE TABLE domainmetadata (
 id                     INTEGER PRIMARY KEY,
 domain_id              INT NOT NULL,
 kind                   VARCHAR(32) COLLATE NOCASE,
 content                TEXT,
 FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX domainmetaidindex ON domainmetadata(domain_id);


CREATE TABLE cryptokeys (
 id                     INTEGER PRIMARY KEY,
 domain_id              INT NOT NULL,
 flags                  INT NOT NULL,
 active                 BOOL,
 published              BOOL DEFAULT 1,
 content                TEXT,
 FOREIGN KEY(domain_id) REFERENCES domains(id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE INDEX domainidindex ON cryptokeys(domain_id);


CREATE TABLE tsigkeys (
 id                     INTEGER PRIMARY KEY,
 name                   VARCHAR(255) COLLATE NOCASE,
 algorithm              VARCHAR(50) COLLATE NOCASE,
 secret                 VARCHAR(255)
);

CREATE UNIQUE INDEX namealgoindex ON tsigkeys(name, algorithm);
" | sqlite3 /etc/pdns/pdns.sqlite


# Use sqlite backend
sed -i 's/^launch=.*$/launch=gsqlite3/' /etc/pdns/pdns.conf
echo 'gsqlite3-database=/etc/pdns/pdns.sqlite' >> /etc/pdns/pdns.conf



if [[ $HOSTNAME =~ .*pdns1 ]]; then
    # PDNS1
    # This runs an authorative and a recursor
    yum install -y pdns-recursor dnsdist

    # Authorative - listening on 127.0.0.1:53
    echo 'local-address=127.0.0.1' >> /etc/pdns/pdns.conf
    echo 'local-port=5300' >> /etc/pdns/pdns.conf

    # Recursor - listening on 0.0.0.0:53
    echo 'local-address=0.0.0.0' >> /etc/pdns-recursor/pdns-recursor.conf
    echo "forward-zones+=sub.example.com=${NODE_2_IP}" >> /etc/pdns-recursor/recursor.conf

    cat <<EOF > /etc/pdns-recursor/mask.lua
    pdnslog("Mask script starting", pdns.loglevels.Warning)

    function nxdomain(dq)


    end
EOF


    systemctl start pdns
    systemctl start pdns-recursor

    # Test data
    pdnsutil create-zone sub.example.com
    pdnsutil add-record sub.example.com ns1 A 3600 "${NODE_1_IP}"
    pdnsutil add-record sub.example.com @ NS ns1.sub.example.com
    pdnsutil add-record sub.example.com one A 3600 192.0.2.1
    pdnsutil add-record sub.example.com both A 3600 192.0.2.11

else
    # PDNS2
    # This just runs an authorative on 127.0.0.1:53
    systemctl start pdns

    # Test data
    pdnsutil create-zone sub.example.com
    pdnsutil add-record sub.example.com ns2 A 3600 "${NODE_2_IP}"
    pdnsutil add-record sub.example.com @ NS ns2.sub.example.com
    pdnsutil add-record sub.example.com two A 3600 192.0.2.2
    pdnsutil add-record sub.example.com both A 3600 192.0.2.22
fi
