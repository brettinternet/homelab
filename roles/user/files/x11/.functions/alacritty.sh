#!/bin/bash

# Change alacritty colorscheme
# Source: https://github.com/russelldavies/dotfiles/blob/176b5827b9a62f196e92589f060564293c8c5024/functions#L50
function terminal-scheme () {
    CONFIG_FILE="$HOME/.config/alacritty/alacritty.yml"
    sed -i "s/\(^colors: \*\).*/\1$1/g" "$CONFIG_FILE"
}
