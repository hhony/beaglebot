#!/bin/bash
FILE=BB-PRUTEST
VER=00A0
dtc -O dtb -o $FILE-$VER.dtbo -b 0 -@ $FILE-$VER.dts
cp $FILE-$VER.dtbo /lib/firmware
echo $FILE >/sys/devices/bone_capemgr.*/slots

