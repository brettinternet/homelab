#!/bin/bash

# https://wiki.archlinux.org/index.php/Xdg-utils#xdg-settings
xdg-settings set default-web-browser chromium.desktop

# https://wiki.archlinux.org/index.php/Nemo#Set_Nemo_as_default_file_browser
xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

# https://wiki.archlinux.org/index.php/Nemo#Show_/_hide_desktop_icons
gsettings set org.nemo.desktop show-desktop-icons false
gsettings set org.nemo.preferences desktop-is-home-dir false

# https://wiki.archlinux.org/index.php/Nemo#Change_the_default_terminal_emulator_for_Nemo
gsettings set org.cinnamon.desktop.default-applications.terminal exec i3-sensible-terminal

# https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally
npm config set prefix '~/.npm-global'
