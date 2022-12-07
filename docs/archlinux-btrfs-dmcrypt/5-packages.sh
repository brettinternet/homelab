#!/bin/bash

set -xe

pacman -Sy --noconfirm archlinux-keyring

PACKAGES=(
  # arch
  base
  base-devel
  linux
  linux-firmware
  linux-headers
  # vendor
  intel-ucode
  # filesystem
  btrfs-progs
  # net
  iwd
  dhcpcd
  networkmanager
  # utility
  vim
  git
  curl
  openssh
  sudo
  gptfdisk
  btop
)

pacstrap /mnt ${PACKAGES[@]}
