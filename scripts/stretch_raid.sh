#!/bin/bash

# Install linux software RAID
apt-get install mdadm -y

# Partition disks
for disk in b c d e f g h i j; do
    sfdisk /dev/sd${disk} << EOF
label: dos
label-id: 0x6dcc49f5
device: /dev/sdb
unit: sectors

/dev/sdb1 : start=        2048, size=     4192256, type=fd
EOF
done

# Create RAID arrays
# -R needed to skip metadata version warning
mdadm -C /dev/md0 -l 1 -n 2 /dev/sdb1 /dev/sdc1 -R
mdadm -C /dev/md1 -l 1 -n 2 -x 1 /dev/sdd1 /dev/sde1 /dev/sdf1 -R
mdadm -C /dev/md2 -l 1 -n 2 /dev/sdg1 /dev/sdh1 -R
mdadm -C /dev/md3 -l 1 -n 2 /dev/sdi1 /dev/sdj1 -R

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
