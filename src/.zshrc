export SHELL="zsh"

source $HOME/.profile

source $HOME/.aliases

source $HOME/.config/broot/launcher/bash/br
source /usr/share/nvm/init-nvm.sh

# Source functions
[ -d "$MY_FUNCTIONS" ] && for i ($MY_FUNCTIONS/*.sh(D)) source $i
[ -d "$MY_FUNCTIONS" ] && for i ($MY_FUNCTIONS/*.zsh(D)) source $i
# TODO: autoload test of functions the proper way

fpath+=( $MY_FUNCTIONS )
autoload -Uz clock zman colortest


# -- Options ----------------------------------------

HISTFILE=~/.histfile
HISTSIZE=50000
SAVEHIST=10000

setopt interactive_comments
setopt append_history hist_ignore_dups hist_ignore_space hist_expire_dups_first
setopt inc_append_history # OR share_history
setopt pushd_ignore_dups
setopt auto_cd beep notify nomatch
setopt extended_glob glob_dots list_packed
setopt auto_pushd pushd_silent pushd_to_home pushd_ignore_dups pushd_minus
setopt auto_menu always_to_end complete_in_word
unsetopt flow_control menu_complete


# -- Bindkeys ----------------------------------------

bindkey -e # emacs mode

# Source: https://wiki.archlinux.org/index.php/Zsh#Key_bindings
#
# create a zkbd compatible hash;
# to add other keys to this hash, see: man 5 terminfo
typeset -g -A key

key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Insert]="${terminfo[kich1]}"
key[Backspace]="${terminfo[kbs]}"
key[Delete]="${terminfo[kdch1]}"
key[Up]="${terminfo[kcuu1]}"
key[Down]="${terminfo[kcud1]}"
key[Left]="${terminfo[kcub1]}"
key[Right]="${terminfo[kcuf1]}"
key[PageUp]="${terminfo[kpp]}"
key[PageDown]="${terminfo[knp]}"
key[ShiftTab]="${terminfo[kcbt]}"

# setup key accordingly
[[ -n "${key[Home]}"      ]] && bindkey -- "${key[Home]}"      beginning-of-line
[[ -n "${key[End]}"       ]] && bindkey -- "${key[End]}"       end-of-line
[[ -n "${key[Insert]}"    ]] && bindkey -- "${key[Insert]}"    overwrite-mode
[[ -n "${key[Backspace]}" ]] && bindkey -- "${key[Backspace]}" backward-delete-char
[[ -n "${key[Delete]}"    ]] && bindkey -- "${key[Delete]}"    delete-char
[[ -n "${key[Up]}"        ]] && bindkey -- "${key[Up]}"        up-line-or-history
[[ -n "${key[Down]}"      ]] && bindkey -- "${key[Down]}"      down-line-or-history
[[ -n "${key[Left]}"      ]] && bindkey -- "${key[Left]}"      backward-char
[[ -n "${key[Right]}"     ]] && bindkey -- "${key[Right]}"     forward-char
[[ -n "${key[PageUp]}"    ]] && bindkey -- "${key[PageUp]}"    beginning-of-buffer-or-history
[[ -n "${key[PageDown]}"  ]] && bindkey -- "${key[PageDown]}"  end-of-buffer-or-history
[[ -n "${key[ShiftTab]}"  ]] && bindkey -- "${key[ShiftTab]}"  reverse-menu-complete

# Finally, make sure the terminal is in application mode, when zle is
# active. Only then are the values from $terminfo valid.
if (( ${+terminfo[smkx]} && ${+terminfo[rmkx]} )); then
    autoload -Uz add-zle-hook-widget
    function zle_application_mode_start {
        echoti smkx
    }
    function zle_application_mode_stop {
        echoti rmkx
    }
    add-zle-hook-widget -Uz zle-line-init zle_application_mode_start
    add-zle-hook-widget -Uz zle-line-finish zle_application_mode_stop
fi

autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

[[ -n "${key[Up]}"   ]] && bindkey -- "${key[Up]}"   up-line-or-beginning-search
[[ -n "${key[Down]}" ]] && bindkey -- "${key[Down]}" down-line-or-beginning-search


# -- Modules ----------------------------------------

zmodload -i zsh/complist


# -- Autoloads ----------------------------------------

autoload -Uz colors
colors

autoload -Uz edit-command-line
zle -N edit-command-line

autoload -Uz select-word-style
select-word-style shell


# -- Hooks ----------------------------------------

autoload -Uz add-zsh-hook

# Source: https://wiki.archlinux.org/index.php/Zsh#On-demand_rehash
ZSHCACHE_TIME="$(date +%s%N)"
rehash_precmd() {
    local REHASH_FILE="$HOME/.cache/zsh/rehash"
    if [[ -a "$REHASH_FILE" ]]; then
        local CACHE_TIME="$(date -r $REHASH_FILE +%s%N)"
        if (( ZSHCACHE_TIME < CACHE_TIME )); then
            rehash
            ZSHCACHE_TIME="$CACHE_TIME"
        fi
    fi
}

add-zsh-hook -Uz precmd rehash_precmd


#PS1="READY > "


# -- Zinit ----------------------------------------
#
# Comparison of all ZSH plugin managers https://www.reddit.com/r/zsh/comments/ak0vgi/a_comparison_of_all_the_zsh_plugin_mangers_i_used/

### Added by Zinit's installer
if [[ ! -f $HOME/.zinit/bin/zinit.zsh ]]; then
    print -P "%F{33}▓▒░ %F{220}Installing DHARMA Initiative Plugin Manager (zdharma/zinit)…%f"
    command mkdir -p "$HOME/.zinit" && command chmod g-rwX "$HOME/.zinit"
    command git clone https://github.com/zdharma/zinit "$HOME/.zinit/bin" && \
        print -P "%F{33}▓▒░ %F{34}Installation successful.%f" || \
        print -P "%F{160}▓▒░ The clone has failed.%f"
fi
source "$HOME/.zinit/bin/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit
### End of Zinit installer's chunk

# -- Plugins via zinit ----------------------------------------
#
# Helpful plugin list: https://github.com/zdharma/Zsh-100-Commits-Club

# Fast-syntax-highlighting & autosuggestions
zinit wait lucid for \
 atinit"ZINIT[COMPINIT_OPTS]=-C; zpcompinit; zpcdreplay" \
    zdharma/fast-syntax-highlighting \
 atload"!_zsh_autosuggest_start" \
    zsh-users/zsh-autosuggestions \
 blockf \
    zsh-users/zsh-completions

# -- Colorscheme
#
# dark version
zplugin snippet https://github.com/sainnhe/dotfiles/blob/master/.zsh-theme-gruvbox-material-dark
# light version
# zplugin snippet https://github.com/sainnhe/dotfiles/blob/master/.zsh-theme-gruvbox-material-light

# -- Prompt
#
# Prompt selection method source: https://github.com/zdharma/zinit-configs/blob/b47a3a92f77cf4d7afbea9070a0a1db69cfed517/psprint/zshrc.zsh#L310
# In case I add more prompts...

# https://github.com/geometry-zsh/geometry
# Options: https://github.com/geometry-zsh/geometry/blob/acf8febcecf3bad2bd91963506a5b26ccc955270/options.md
zinit lucid load'![[ $MYPROMPT = 1 ]]' unload'![[ $MYPROMPT != 1 ]]' \
 atload'!geometry::prompt' nocd \
 atinit'GEOMETRY_PATH_COLOR=04; GEOMETRY_STATUS_COLOR=05' for \
    geometry-zsh/geometry

MYPROMPT=1

# Fish Alt+l mimic
zstyle ":completion:file-complete::::" completer _files
zle -C file-complete complete-word _generic
zstyle -e ':completion:*:default' list-colors 'reply=("${PREFIX:+=(#bi)($PREFIX:t)(?)*==04=02}:${(s.:.)LS_COLORS}")'
zstyle ':completion:*' menu select
bindkey '^[l' file-complete

zstyle ':completion::complete:*' use-cache 1
zstyle ':completion::complete:*' cache-path $ZSH_CACHE_DIR
# zstyle ':completion:*' list-colors ''
# zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;34=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:kill:*'   force-list always
zstyle ":completion:*:descriptions" format "%B%d%b"
#zstyle ':completion:*:*:*:default' menu yes select search
