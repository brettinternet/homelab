#!/bin/bash

set -xe

if passwd -S root | grep -q "NP"; then
  echo "Set root password:"
  passwd
fi

systemctl start sshd.service
