#!/bin/bash

# Source: https://github.com/jhawthorn/fzy/wiki

function fvim {
    FILE=$(ag --hidden -l -g '' | fzy)
    vim "$FILE"
}

function fcd {
  cd "$(find -type d -iname "*$1*" | fzy)"
}
