#!/bin/bash

set -xe

BASE_DIR="/mnt"

genfstab -L -p /mnt >> $BASE_DIR/etc/fstab

cat "LABEL=system        /.swap/swapfile    swap        defaults,space_cache,ssd,discard=async,compress=no,subvol=/@swap 0 0" >> $BASE_DIR/etc/fstab

cat $BASE_DIR/etc/fstab
