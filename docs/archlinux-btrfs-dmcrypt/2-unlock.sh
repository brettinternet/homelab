#!/bin/bash

set -xe

cryptsetup \
    --allow-discards \
    --perf-no_read_workqueue \
    --perf-no_write_workqueue \
    --persistent \
    open /dev/disk/by-partlabel/cryptsystem system
