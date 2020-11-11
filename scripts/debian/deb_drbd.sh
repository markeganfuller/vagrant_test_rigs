#!/bin/bash

function mount_disks(){
    for i in 1 2; do
        mkdir "/mnt/${i}"
        echo "/dev/drbd${i} /mnt/${i} ext4 defaults 0 0" >> /etc/fstab
    done
    mount -a
}

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

cat <<EOF > /etc/drbd.d/test2.res
resource test2 {
  device /dev/drbd2;
  syncer {
    rate 400M;
    verify-alg sha1;
  }
  on stretch-drbd1 {
    disk /dev/vdc;
    address 192.168.33.34:7790;
    meta-disk internal;
  }
  on stretch-drbd2 {
    disk /dev/vdc;
    address 192.168.33.35:7790;
    meta-disk internal;
  }
}
EOF

drbdadm create-md test
drbdadm create-md test2
drbdadm up test
drbdadm up test2


if [ "$HOSTNAME" == "stretch-drbd1" ]; then
    # If we're 1 make us primary and setup the FS / test data
    # Overwrite for initialisation
    drbdadm -- --overwrite-data-of-peer primary test
    drbdadm -- --overwrite-data-of-peer primary test2
    mkfs.ext4 /dev/drbd1
    mkfs.ext4 /dev/drbd2

    mount_disks

    echo "Test data 1" > /mnt/test_data_1
    echo "Test data 2" > /mnt/test_data_2
else
    # If we're on 2 just mount the disks
    mount_disks
fi


cat /proc/drbd
