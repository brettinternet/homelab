# tty1 - https://wiki.archlinux.org/index.php/Silent_boot#startx
[[ $(fgconsole 2>/dev/null) == 1 ]] && exec startx -- vt1 &> /dev/null

# Only run in interactive mode and file exists
[[ $- == *i* ]] && [ -f $HOME/.bashrc ] && . $HOME/.bashrc
