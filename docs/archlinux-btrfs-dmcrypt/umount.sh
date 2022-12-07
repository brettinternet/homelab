#!/bin/bash

set -xe

swapoff -a
umount -R /mnt
cryptsetup close system
cryptsetup close swap
