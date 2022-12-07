#!/bin/bash

set -xe

# https://wiki.archlinux.org/title/Dm-crypt/Drive_preparation

DRIVE="/dev/nvme0n1"

sgdisk --zap-all $DRIVE

sgdisk --clear \
       --new=1:0:+550MiB --typecode=1:ef00 --change-name=1:EFI \
       --new=2:0:0       --typecode=2:8300 --change-name=2:cryptsystem \
       $DRIVE

lsblk -o +PARTLABEL

mkfs.fat -F32 -n EFI /dev/disk/by-partlabel/EFI

cryptsetup luksFormat \
    --perf-no_read_workqueue \
    --perf-no_write_workqueue \
    --type luks2 \
    --cipher aes-xts-plain64 \
    --key-size 512 \
    --iter-time 2000 \
    --pbkdf argon2id \
    --hash sha3-512 \
    /dev/disk/by-partlabel/cryptsystem
