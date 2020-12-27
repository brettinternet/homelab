# tty1 - https://wiki.archlinux.org/index.php/Silent_boot#startx
# Rootless Xorg - https://wiki.archlinux.org/index.php/Xorg#Rootless_Xorg
[[ $(fgconsole 2>/dev/null) == 1 ]] && startx -- vt1 &> /dev/null
