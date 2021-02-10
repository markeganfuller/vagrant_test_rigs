#!/bin/bash

NODE_1_IP=$1
NODE_2_IP=$2

apt-get install -y gvpe

cat <<EOF > /etc/gvpe/gvpe.conf
udp-port = 50000 # the external port to listen on (configure your firewall)
mtu = 1400       # minimum MTU of all outgoing interfaces on all hosts
ifname = vpn0    # the local network device name
enable-rawip = yes

node = stretch-gvpe1     # just a nickname
hostname = ${NODE_1_IP} # the DNS name or IP address of the host

node = stretch-gvpe2
hostname = ${NODE_2_IP}
EOF

cat <<'EOF' > /etc/gvpe/if-up
#!/bin/sh
ip link set $IFNAME address $MAC mtu $MTU up
[ $NODENAME = stretch-gvpe1 ] && ip addr add 10.239.32.1 dev $IFNAME
[ $NODENAME = stretch-gvpe2 ] && ip addr add 10.239.32.2 dev $IFNAME
ip route add 10.239.32.0/24 dev $IFNAME
EOF

chmod +x /etc/gvpe/if-up

sed -i 's/START_DAEMON="0"/START_DAEMON="1"/' /etc/default/gvpe
sed -i "s/# DAEMON_ARGS=\"\"/DAEMON_ARGS=\"${HOSTNAME}\"/" /etc/default/gvpe

if [[ $HOSTNAME == "stretch-gvpe1" ]]; then
    # On node 1 we setup keys
    gvpectrl -c /etc/gvpe -g nodekey

    ln -s /etc/gvpe/hostkeys/stretch-gvpe1 /etc/gvpe/hostkey

    # Then cp the keys for node to to the shared folder
    mkdir -p /vagrant/tmp/gvpe/pubkey
    cp /etc/gvpe/pubkey/stretch-gvpe1 "/vagrant/tmp/gvpe/pubkey/stretch-gvpe1"
    cp /etc/gvpe/pubkey/stretch-gvpe2 "/vagrant/tmp/gvpe/pubkey/stretch-gvpe2"
    mkdir -p /vagrant/tmp/gvpe/hostkeys
    cp /etc/gvpe/hostkeys/stretch-gvpe2 "/vagrant/tmp/gvpe/hostkeys/stretch-gvpe2"

else
    # On node2 we symlink to the keys in the shared folder
    mkdir /etc/gvpe/pubkey
    ln -s /vagrant/tmp/gvpe/pubkey/stretch-gvpe1 /etc/gvpe/pubkey/stretch-gvpe1
    ln -s /vagrant/tmp/gvpe/pubkey/stretch-gvpe2 /etc/gvpe/pubkey/stretch-gvpe2
    mkdir /etc/gvpe/hostkeys
    ln -s /vagrant/tmp/gvpe/hostkeys/stretch-gvpe2 /etc/gvpe/hostkey
fi

systemctl restart gvpe
