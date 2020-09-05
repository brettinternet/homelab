#!/bin/bash

# Source: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins/git

# Source: https://github.com/ohmyzsh/ohmyzsh/blob/4e45e12dc355e3ba34e7e40ce4936fb222f0155c/plugins/git/git.plugin.zsh#L21-L26
# These features allow to pause a branch development and switch to another one ("Work in Progress", or wip). When you want to go back to work, just unwip it.
# Warn if the current branch is a WIP
function work_in_progress() {
  if $(git log -n 1 2>/dev/null | grep -q -c "\-\-wip\-\-"); then
    echo "WIP!!"
  fi
}

# Source: https://github.com/ohmyzsh/ohmyzsh/blob/4e45e12dc355e3ba34e7e40ce4936fb222f0155c/plugins/git/git.plugin.zsh#L257
alias gwip='git add -A; git rm $(git ls-files --deleted) 2> /dev/null; git commit --no-verify --no-gpg-sign -m "--wip-- [skipci]"'
alias gunwip='git log -n 1 | grep -q -c "\-\-wip\-\-" && git reset HEAD~1'

# Source: https://github.com/ohmyzsh/ohmyzsh/blob/1546e1226a7b739776bda43f264b221739ba0397/lib/git.zsh#L68-L81
# Outputs the name of the current branch
# Usage example: git pull origin $(git_current_branch)
# Using '--quiet' with 'symbolic-ref' will not cause a fatal error (128) if
# it's not a symbolic ref, but in a Git repo.
function git_current_branch() {
  local ref
  ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
  local ret=$?
  if [[ $ret != 0 ]]; then
    [[ $ret == 128 ]] && return  # no git repo.
    ref=$(command git rev-parse --short HEAD 2> /dev/null) || return
  fi
  echo ${ref#refs/heads/}
}

alias guc='git pull origin "$(git_current_branch)"'
alias gpc='git push origin "$(git_current_branch)"'

alias gbsuc='git branch --set-upstream-to=origin/$(git_current_branch)'
alias gpsuc='git push --set-upstream origin $(git_current_branch)'
