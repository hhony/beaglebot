#!/bin/sh
echo timer > /sys/class/leds/beaglebone\:green\:usr0/trigger 

ENABLE_COPY=1
VERSION="4_1_5"

if [ $ENABLE_COPY -eq 1 ]; then
  # perform a backup
  echo "[INFO] backing up: /mnt/BBB-eMMC-${VERSION}.img.gz"
  dd if=/dev/mmcblk1 bs=16M | gzip -c > /mnt/BBB-eMMC-${VERSION}.img.gz
  if [ -f /mnt/BBB-eMMC-${VERSION}.img.gz ]; then
    mv /mnt/BBB-eMMC-${VERSION}.img.gz `pwd`
  fi
else
  # perform a restore
  echo "[INFO] restoring: BBB-eMMC-${VERSION}.img.gz"
  gunzip -c `pwd`/BBB-eMMC-${VERSION}.img.gz | dd of=/dev/mmcblk0 bs=16M
  
  if [ ! -d /tmp ]; then
    mkdir -p /tmp
  else
    rm -rf /tmp/*
  fi
  mount /dev/mmcblk0p2 /tmp
  
  unset root_uuid
  root_uuid=$(/sbin/blkid -c /dev/null -s UUID -o value mmcblk0p2)
  if [ "${root_uuid}" ] ; then
    root_uuid="UUID=${root_uuid}"
    device_id=$(cat /tmp/boot/uEnv.txt | grep mmcroot | grep mmcblk | awk '{print $1}' | awk -F '=' '{print $2}')
    if [ ! "${device_id}" ] ; then
      device_id=$(cat /tmp/boot/uEnv.txt | grep mmcroot | grep UUID | awk '{print $1}' | awk -F '=' '{print $3}')
      device_id="UUID=${device_id}"
    fi
    sed -i -e 's:'${device_id}':'${root_uuid}':g' /tmp/boot/uEnv.txt
  else
    root_uuid="mmcblk0p2"
  fi
  
  umount /tmp
fi

sync
echo default-on > /sys/class/leds/beaglebone\:green\:usr0/trigger
