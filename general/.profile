#!/bin/sh

# To allow for some customization across workspaces
WORKSPACE_ONLY_ENV=$HOME/.env
if [ -f $WORKSPACE_ONLY_ENV ]; then
    . $WORKSPACE_ONLY_ENV
fi

# https://wiki.archlinux.org/index.php/Sudo#Using_visudo
export VISUAL=vim
export EDITOR=vim

# If we haven't set the shell yet, use bash
if [ -z "$SHELL" ]; then
    export SHELL=bash
fi

# https://guides.rubygems.org/faqs/#user-install
if which ruby >/dev/null && which gem >/dev/null; then
    PATH="$(ruby -r rubygems -e 'puts Gem.user_dir')/bin:$PATH"
fi
# https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally
export PATH=~/.npm-global/bin:$PATH

# https://wiki.archlinux.org/index.php/Environment_variables#Default_programs
if [ -n "$DISPLAY" ]; then
    export BROWSER=firefox
else
    export BROWSER=w3m
fi
