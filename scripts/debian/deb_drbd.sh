#!/bin/bash

apt-get install -y drbd8-utils

cat <<EOF > /etc/drbd.d/test.res
resource test {
  device /dev/drbd1;
  syncer {
    rate 400M;
    verify-alg sha1;
  }
  on stretch-drbd1 {
    disk /dev/vdb;
    address 192.168.33.34:7789;
    meta-disk internal;
  }
  on stretch-drbd2 {
    disk /dev/vdb;
    address 192.168.33.35:7789;
    meta-disk internal;
  }
}
EOF

drbdadm create-md test
drbdadm up test


# If we're 1 make us primary
if [ "$HOSTNAME" == "stretch-drbd1" ]; then
    # Overwrite for initialisation
    drbdadm -- --overwrite-data-of-peer primary test
    mkfs.ext4 /dev/drbd1
    mount /dev/drbd1 /mnt
    echo "Test data" > /mnt/test_data
else
    mount /dev/drbd1 /mnt
fi


cat /proc/drbd
