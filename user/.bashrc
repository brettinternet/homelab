# Only run interactively
# https://unix.stackexchange.com/a/257613/224048
[[ $- != *i* ]] && return

export SHELL="/bin/bash"

PS1='[\u@\h \W]\$ '

source $HOME/.profile

source $HOME/.aliases
[ -d "$MY_FUNCTIONS" ] && for i in $MY_FUNCTIONS/*.sh; do source $i; done

source $HOME/.config/broot/launcher/bash/br
source /usr/share/nvm/init-nvm.sh

# -- Fish ----------------------------------------

# https://wiki.archlinux.org/index.php/Fish#Setting_fish_as_interactive_shell_only
#if [ -z "$BASH_EXECUTION_STRING" ]; then exec fish; fi
