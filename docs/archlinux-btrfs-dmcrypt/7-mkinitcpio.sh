#!/bin/bash

set -xe

BASE_DIR="/mnt"

# vconsole
# https://wiki.archlinux.org/title/Linux_console/Keyboard_configuration

cat > $BASE_DIR/etc/vconsole.conf <<EOF
KEYMAP=us
keycode 1 = Caps_Lock
keycode 58 = Escape
EOF

# mkinitcpio
# https://wiki.archlinux.org/title/mkinitcpio

SCRIPT=/root/setup-mkinitcpio.sh
cat > $BASE_DIR$SCRIPT <<EOF
sed -i 's/^HOOKS/HOOKS=(base systemd autodetect keyboard sd-vconsole modconf block sd-encrypt resume filesystems fsck)/' /etc/mkinitcpio.conf

mkinitcpio -p linux
EOF

chmod +x $BASE_DIR$SCRIPT

arch-chroot /mnt $SCRIPT

rm $BASE_DIR$SCRIPT

cat $BASE_DIR/etc/mkinitcpio.conf
