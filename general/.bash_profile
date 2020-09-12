DEBUG=false

run_startx () {
  if [ "$DEBUG" = true ]; then
    exec startx -- -keeptty &> /var/log/startx.log
  else
    exec startx -- vt1 &> /dev/null
  fi
}

# tty1 - https://wiki.archlinux.org/index.php/Silent_boot#startx
[[ $(fgconsole 2>/dev/null) == 1 ]] && run_startx

# Only run in interactive mode and file exists
[[ $- == *i* ]] && [ -f $HOME/.bashrc ] && . $HOME/.bashrc
