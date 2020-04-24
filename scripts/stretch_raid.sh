#!/bin/bash

# Install linux software RAID
apt-get install mdadm -y

# Partition disks
if lsblk | grep sda -q; then
    disk_name=sd
elif lsblk | grep vda -q; then
    disk_name=vd
else
    echo "Unknown disk naming scheme"
    exit 1
fi

for disk in b c d e f g h i j; do
    sfdisk /dev/${disk_name}${disk} << EOF
label: dos
label-id: 0x6dcc49f5
device: /dev/sdb
unit: sectors

/dev/sdb1 : start=        2048, size=     4192256, type=fd
EOF
done

# Create RAID arrays
# -R needed to skip metadata version warning
mdadm -C /dev/md0 -l 1 -n 2 /dev/${disk_name}b1 /dev/${disk_name}c1 -R
mdadm -C /dev/md1 -l 1 -n 2 -x 1 /dev/${disk_name}d1 /dev/${disk_name}e1 /dev/${disk_name}f1 -R
mdadm -C /dev/md2 -l 1 -n 2 /dev/${disk_name}g1 /dev/${disk_name}h1 -R
mdadm -C /dev/md3 -l 1 -n 2 /dev/${disk_name}i1 /dev/${disk_name}j1 -R

for i in {0..3}; do
    # Format RAID arrays
    mkfs.ext4 /dev/md${i}

    # Create mount points
    mkdir /mnt/disk${i}

    # Update fstab and mount
    echo "/dev/md${i} /mnt/disk${i} ext4 defaults 0 1" >> /etc/fstab
done
mount -a

# Update config
mdadm --examine --scan \
    | grep ARRAY  \
    | sed 's/$/ spare-group=example/' \
    > /etc/mdadm/mdadm.conf

echo "MAILADDR root" >> /etc/mdadm/mdadm.conf

# Update initramfs
update-initramfs -k all -u
