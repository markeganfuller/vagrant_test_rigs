#!/bin/bash

NFS_SERVER=$1

yum install -y nfs-utils

mkdir /mnt/nfsshare

cat <<EOF >> /etc/fstab
${NFS_SERVER}:/mnt/nfsshare /mnt/nfsshare nfs defaults 0 0
EOF

mount -a
