#!/bin/bash

# -- Run clean up occasionally ------------------

# Remove pacman orphans
sudo pacman -Rns $(pacman -Qtdq)

# Update configuration files
# https://wiki.archlinux.org/index.php/Pacman/Pacnew_and_Pacsave
sudo pacdiff

# Clean up pacman cache
sudo pacman -Sc
