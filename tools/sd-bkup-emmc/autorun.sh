#!/bin/sh
echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger 

ENABLE_COPY=1
VERSION="4_1_5"

if [ $ENABLE_COPY -eq 1 ]; then
  # perform a backup
  echo "[INFO] backing up: /mnt/BBB-eMMC-${VERSION}.img.gz"
  dd if=/dev/mmcblk1 bs=16M | gzip -c > /mnt/BBB-eMMC-${VERION}.img.gz
else
  # perform a restore
  echo "[INFO] restoring: /mnt/BBB-eMMC-${VERSION}.img.gz"
  gunzip -c /mnt/BBB-eMMC-${VERSION}.img.gz | dd of=/dev/mmcblk1 bs=16M
  UUID=$(/sbin/blkid -c /dev/null -s UUID -o value /dev/mmcblk1p2)
  mkdir -p /mnt
  mount /dev/mmcblk1p2 /mnt
  sed -i "s/^uuid=.*\$/uuid=$UUID/" /mnt/boot/uEnv.txt
  umount /mnt
fi

sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
