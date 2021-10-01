#!/bin/bash
set -x

NODE_1_IP=$1
NODE_2_IP=$2
REPMGR_PASS='reppass'

echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list
wget --quiet -O - --no-check-certificate https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -

apt-get update

apt-get install -y postgresql-11 postgresql-11-repmgr

if [[ $HOSTNAME == "stretch-psql1" ]]; then
    NODE_ID=1
    NODE_NAME="psql1"
    NODE_IP=$NODE_1_IP
else
    NODE_ID=2
    NODE_NAME="psql2"
    NODE_IP=$NODE_2_IP
fi

cat <<EOF > /etc/repmgr.conf
node_id=${NODE_ID}
node_name=${NODE_NAME}
conninfo='host=${NODE_IP} port=5432 user=repmgr dbname=repmgr connect_timeout=10'
data_directory='/var/lib/postgresql/11/main'
config_directory='/etc/postgresql/11/main'
log_file='/var/log/postgresql/repmgrd.log'

replication_user='replicator'
use_replication_slots=yes

monitoring_history=yes

service_start_command   = 'sudo /usr/bin/pg_ctlcluster 11 main start'
service_stop_command    = 'sudo /usr/bin/pg_ctlcluster 11 main stop'
service_restart_command = 'sudo /usr/bin/pg_ctlcluster 11 main restart'
service_reload_command  = 'sudo /usr/bin/pg_ctlcluster 11 main reload'
service_promote_command = 'sudo /usr/bin/pg_ctlcluster 11 main promote'

failover=manual
EOF

echo "listen_addresses='*'" >> /etc/postgresql/11/main/postgresql.conf
cat <<EOF >> /etc/postgresql/11/main/pg_hba.conf
host    all             all             192.168.33.49/32        md5
host    all             all             192.168.33.50/32        md5
host    replication     all             192.168.33.49/32        md5
host    replication     all             192.168.33.50/32        md5
EOF

echo "*:*:*:*:reppass" >> /var/lib/postgresql/.pgpass
chown postgres:postgres /var/lib/postgresql/.pgpass
chmod 0600 /var/lib/postgresql/.pgpass

systemctl restart postgresql

if [[ $HOSTNAME == "stretch-psql1" ]]; then
    echo "${NODE_2_IP} stretch-psql2" >> /etc/hosts

    sudo -u postgres psql -c "CREATE ROLE repmgr LOGIN PASSWORD '${REPMGR_PASS}';"
    sudo -u postgres psql -c "ALTER USER repmgr WITH SUPERUSER;"
    sudo -u postgres psql -c "CREATE DATABASE repmgr OWNER repmgr;"


    sudo -u postgres psql -c "CREATE ROLE replicator LOGIN PASSWORD '${REPMGR_PASS}';"
    sudo -u postgres psql -c "ALTER USER replicator WITH REPLICATION;"

    sudo -u postgres repmgr -f /etc/repmgr.conf primary register
else
    echo "${NODE_1_IP} stretch-psql1" >> /etc/hosts
    systemctl stop postgresql
    sleep 10
    sudo -u postgres repmgr -h stretch-psql1 -U repmgr -d repmgr -p 5432 -f /etc/repmgr.conf standby clone -F
    systemctl start postgresql
    sudo -u postgres repmgr -f /etc/repmgr.conf standby register
fi

sudo -u postgres repmgr -f /etc/repmgr.conf cluster show
