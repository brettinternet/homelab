#!/bin/bash

set -xe

BASE_DIR="/mnt"

PASSWORD_STATUS=$(./run-chrooted.sh passwd -S root)
if echo $PASSWORD_STATUS | grep -q "NP"; then
  echo "Set root password:"
  ./run-chrooted.sh passwd
fi

TIMEZONE=${TZ:-America/Denver}

echo "en_US.UTF-8 UTF-8" > $BASE_DIR/etc/locale.gen
./run-chrooteded.sh locale-gen
echo LANG=en_US.UTF-8 > $BASE_DIR/etc/locale.conf
ln -nsf $BASE_DIR/usr/share/zoneinfo/$TIMEZONE $BASE_DIR/etc/localtime
./run-chrooted.sh hwclock --systohc --utc

echo "Next steps: setup hostname"
