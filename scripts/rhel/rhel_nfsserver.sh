#!/bin/bash

# e.g 192.0.2 which we will treat as /24
IP_NETWORK=$1

echo $1
# Setup NFSv3 server on RHEL

# Setup disk
if lsblk | grep sdb -q; then
    disk_name=sdb
elif lsblk | grep vdb -q; then
    disk_name=vdb
else
    echo "Unknown disk naming scheme"
    exit 1
fi

# Partition disk
sfdisk -uS /dev/${disk_name} << EOF
/dev/${disk_name}1 : start=        2048, size=     4192256,
EOF

mkfs.ext4 "/dev/${disk_name}1"

cat <<EOF >> /etc/fstab
/dev/${disk_name}1 /mnt/nfsshare ext4 defaults 0 0
EOF

mkdir /mnt/nfsshare

mount -a

# Dependencies
yum install -y nfs-utils rpcbind

# Config
cat <<EOF > /etc/exports
/mnt/nfsshare ${IP_NETWORK}0/24(rw,no_root_squash)
EOF

# Services
systemctl enable nfs-server
systemctl enable rpcbind
systemctl start nfs-server
systemctl start rpcbind
