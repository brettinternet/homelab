#!/bin/bash

set -xe

# Mount subvolumes

BASE_DIR="/mnt"

# autodefrag option not recommended for now: https://lore.kernel.org/linux-btrfs/87k0cvnklg.fsf@vps.thesusis.net/T/#m6c5617d6088879d825af4321735046ef20277dc7
o=defaults,x-mount.mkdir,noatime,nodiratime,discard=async
o_btrfs=$o,compress=zstd,ssd
o_swap=x-mount.mkdir,space_cache,ssd,discard=async,compress=no

mount -t btrfs -o subvol=@root,$o_btrfs LABEL=system $BASE_DIR
mount -t btrfs -o subvol=@home,$o_btrfs LABEL=system $BASE_DIR/home
mount -t btrfs -o subvol=@snapshots,$o_btrfs LABEL=system $BASE_DIR/.snapshots
mount -t btrfs -o subvol=@swap,$o_swap LABEL=system $BASE_DIR/.swap

if [ ! -f $BASE_DIR/.swap/swapfile ]; then
  # Create swapfile
  # https://wiki.archlinux.org/title/Btrfs#Swap_file
  # https://wiki.archlinux.org/title/Swap#Swap_file_creation
  # https://askubuntu.com/questions/1017309/fallocate-vs-dd-for-swapfile
  # OR use this method: https://btrfs.readthedocs.io/en/latest/Swapfile.html
  SWAP_SIZE=24096
  chattr +C /mnt/.swap
  dd if=/dev/zero of=$BASE_DIR/.swap/swapfile bs=1M count=$SWAP_SIZE status=progress
  chmod 0600 $BASE_DIR/.swap/swapfile
  mkswap -U clear $BASE_DIR/.swap/swapfile
fi
swapon $BASE_DIR/.swap/swapfile

mount --mkdir /dev/disk/by-partlabel/EFI /mnt/boot

btrfs subvolume list $BASE_DIR
ls $BASE_DIR
