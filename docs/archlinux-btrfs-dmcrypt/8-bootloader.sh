#!/bin/bash

set -xe

BASE_DIR="/mnt"
EFI_MOUNT_DIR="$BASE_DIR/boot"
CONF_DIR="$EFI_MOUNT_DIR/EFI/refind"

run_in_system() {
  arch-chroot /mnt /bin/bash -c "$@"
}

pacstrap /mnt refind

# install refind
refind-install

# install drivers
mkdir -p $CONF_DIR/drivers_x64
DRIVER=btrfs_x64.efi
DRIVER_INSTALL_PATH=$CONF_DIR/drivers_x64/$DRIVER
if [ ! -f $DRIVER_INSTALL_PATH ]; then
  cp /usr/share/refind/drivers_x64/$DRIVER $DRIVER_INSTALL_PATH
fi

# get resume offset for swapfile
# https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Hibernation_into_swap_file_on_Btrfs
# https://github.com/osandov/osandov-linux/blob/master/scripts/btrfs_map_physical.c
MAP_PHYSICAL_C=/usr/local/bin/btrfs_map_physical.c
MAP_PHYSICAL=/usr/local/bin/btrfs_map_physical
curl -sLJo $BASE_DIR$MAP_PHYSICAL_C https://raw.githubusercontent.com/osandov/osandov-linux/master/scripts/btrfs_map_physical.c
run_in_system "gcc -O2 -o $MAP_PHYSICAL $MAP_PHYSICAL_C"
rm $BASE_DIR$MAP_PHYSICAL_C

# theme setup
THEME_NAME=refind-theme-regular
if [ ! -d "$CONF_DIR/themes/$THEME_NAME" ]; then
  mkdir -p $CONF_DIR/themes
  run_in_system "git clone https://github.com/bobafetthotmail/refind-theme-regular.git /boot/EFI/refind/themes/$THEME_NAME"
  rm -rf $CONF_DIR/themes/$THEME_NAME/{src,.git}
  rm $CONF_DIR/themes/$THEME_NAME/install.sh
fi

BACKUP_CONF_PATH="$CONF_DIR/refind.conf.bak"
if [ ! -f "$BACKUP_CONF_PATH" ]; then
  mv $CONF_DIR/refind.conf $BACKUP_CONF_PATH
fi

DRIVE="/dev/nvme0n1"
DRIVE_SYSTEM_PARTITION="/dev/nvme0n1p2"
DRIVE_PART_UUID="$(blkid $DRIVE_SYSTEM_PARTITION | cut -d " " -f2 | cut -d '=' -f2 | sed 's/\"//g')"
RESUME_OFFSET="$(echo $(/mnt/usr/local/bin/btrfs_map_physical /mnt/.swap/swapfile | head -n2 | tail -n1 | awk '{print $6}') / $(run_in_system "getconf PAGESIZE") | bc)"
cat > $CONF_DIR/refind.conf <<EOF
menuentry "Arch Linux" {
    icon     /EFI/refind/themes/$THEME_NAME/icons/128-48/os_arch.png
    volume   "Arch Linux"
    loader   /vmlinuz-linux
    initrd   /initramfs-linux.img
    options  "rd.luks.name=$DRIVE_PART_UUID=system root=/dev/mapper/system rootflags=subvol=@root resume=/dev/mapper/system resume_offset=$RESUME_OFFSET rw quiet nmi_watchdog=0 add_efi_memmap initrd=/intel-ucode.img"
    submenuentry "Boot using fallback initramfs" {
        initrd /boot/initramfs-linux-fallback.img
    }
}

timeout         5
include         themes/$THEME_NAME/theme.conf
also_scan_dirs  +,@root/
resolution     1920 1080
EOF

cat $CONF_DIR/refind.conf
