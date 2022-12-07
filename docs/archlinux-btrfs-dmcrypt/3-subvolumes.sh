#!/bin/bash

set -xe

mkfs.btrfs --force --label system /dev/mapper/system
mount -t btrfs LABEL=system /mnt
btrfs subvolume create /mnt/@root
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
btrfs subvolume create /mnt/@swap
umount -R /mnt
