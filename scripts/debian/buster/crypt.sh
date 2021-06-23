#!/bin/bash
DEBIAN_FRONTEND=noninteractive apt-get install -y cryptsetup pwgen

if lsblk | grep sdb -q; then
    disk_name=sdb
elif lsblk | grep vdb -q; then
    disk_name=vdb
else
    echo "Unknown disk naming scheme"
    exit 1
fi

# Partition disk
sfdisk /dev/${disk_name} << EOF
label: dos
device: /dev/${disk_name}
unit: sectors

/dev/${disk_name}1 : start=        2048, size=     4192256, type=83
EOF

password=$(pwgen 30 1 -c -n -s)
echo "${password}" >> /home/vagrant/luks_password

echo "${password}" | cryptsetup -v luksFormat /dev/${disk_name}1
echo "${password}" | cryptsetup open /dev/${disk_name}1 cryptvol

mkfs.ext4 /dev/mapper/cryptvol

PART_UUID=$(blkid /dev/${disk_name}1 -o value | head -n1)
FS_UUID=$(blkid /dev/mapper/cryptvol -o value | head -n1)

cryptsetup close /dev/mapper/cryptvol

echo "cryptvol UUID=${PART_UUID} none luks,noauto" > /etc/crypttab
echo "UUID=${FS_UUID} /mnt/cryptvol	ext4	noauto,x-systemd.requires=systemd-cryptsetup@cryptvol.service,x-mount.mkdir 0 2" >> /etc/fstab


echo -e "\nLUKS Password: ${password}\n"

echo -e "\nREBOOT!\n"


# Note services needing the encrypted voluime should have:
#   Requires=mnt-cryptvol.mount
#   After=mnt-cryptvol.mount
# They should also NOT be enabled and not set to have WantedBy multi-user.target
