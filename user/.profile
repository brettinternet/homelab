#!/bin/sh

# To allow for some customization across workspaces
local WORKSPACE_ONLY_ENV=$HOME/.env
if [ -f $WORKSPACE_ONLY_ENV ]; then
    . $WORKSPACE_ONLY_ENV
fi

# https://wiki.archlinux.org/index.php/Sudo#Using_visudo
export VISUAL=vim
export EDITOR="$VISUAL"

# https://wiki.archlinux.org/index.php/Environment_variables#Default_programs
if [ ! -n "$DISPLAY" ]; then
    export BROWSER=w3m
fi

# If we haven't set the shell yet, use bash
if [ -z "$SHELL" ]; then
    export SHELL=/bin/bash
fi

# Personal desktop environment scripts,
# more useful here than .profile because .xprofile is loaded before i3 in .xinitrc
local PERSONAL_BIN=${MY_BIN:-$MY_DOTFILES/bin}
if [ -d "$PERSONAL_BIN" ]; then
    export PATH=$PATH:$PERSONAL_BIN
fi

# https://guides.rubygems.org/faqs/#user-install
if which ruby >/dev/null && which gem >/dev/null; then
    export PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi

# global NPM packages: https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally
# Set custom gopath because I prefer it to be a hidden folder
export GOPATH=~/.go
export PATH=~/.npm-global/bin:~/.local/bin:$GOPATH/bin:~/.cargo/bin:$PATH

# Automatically logout inactive consoles after 10 min: https://wiki.archlinux.org/index.php/Security#Automatic_logout
local TMOUT="$(( 60*10 ))";
[ -z "$DISPLAY" ] && export TMOUT;
case $( /usr/bin/tty ) in
	/dev/tty[0-9]*) export TMOUT;;
esac
