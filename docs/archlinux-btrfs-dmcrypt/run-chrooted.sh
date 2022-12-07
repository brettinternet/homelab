#!/bin/bash

set -xe

CHROOT_TARGET=${TARGET:-/mnt}

(( $# )) || exit
# https://stackoverflow.com/a/55598119
ARGS=$(printf '%q ' "$@")

# https://unix.stackexchange.com/a/14346
if [ "$(stat -c %d:%i /)" != "$(stat -c %d:%i /proc/1/root/.)" ]; then
  /bin/bash -c "$ARGS"
else
  arch-chroot $CHROOT_TARGET /bin/bash -c "$ARGS"
fi
