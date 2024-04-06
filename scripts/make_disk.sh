#!/bin/bash
#
# Create a raw qemu disk image from a directory
# hard coded to be 1G for the moment
# used to easy load things into windows vms

set -euo pipefail


INPUT_DIR=$1
OUTPUT_FILE=$2
MOUNTPOINT="/mnt/${OUTPUT_FILE}"

if [ "$EUID" -ne 0 ]
  then echo "Please run as root"
  exit
fi

# Cleanup old outputfile
rm -f "${OUTPUT_FILE}"

qemu-img create -f raw "${OUTPUT_FILE}" 1G

sfdisk "${OUTPUT_FILE}" <<EOF
label: dos
label-id: 0xd7bff409
unit: sectors
sector-size: 512

part1 : start=        2048, size=     2095104, type=c
EOF

losetup -P /dev/loop0 "${OUTPUT_FILE}"
mkfs.fat /dev/loop0p1

mkdir "${MOUNTPOINT}"
mount /dev/loop0p1 "${MOUNTPOINT}"

cp -r "${INPUT_DIR}"/* "${MOUNTPOINT}/"

ls -la "${MOUNTPOINT}"

umount "${MOUNTPOINT}"
rmdir "${MOUNTPOINT}"
losetup -d /dev/loop0
