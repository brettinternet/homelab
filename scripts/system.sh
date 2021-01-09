#!/bin/bash

SCRIPTS_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd)"
SYSTEM_DIR="$SCRIPTS_DIR/../system"

if [ "$EUID" -ne 0 ]; then
    echo "You need to run this script as root"
    exit 1
fi

# Desktop entries: https://wiki.archlinux.org/index.php/Desktop_entries

install -Dm 755 $SYSTEM_DIR/zoom-firejail /usr/bin/zoom-firejail
install -Dm 644 $SYSTEM_DIR/zoom-firejail.desktop /usr/share/applications/zoom-firejail.desktop
