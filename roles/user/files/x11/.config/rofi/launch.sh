#!/usr/bin/bash

rofi \
-show drun \
-terminal $TERM \
-show-icons \
-run-shell-command '{terminal} -e \\" {cmd}; read -n 1 -s\\"' \
-font 'sans-serif 10' \
-modi drun,run,window,ssh \
-lines 5 \
-line-padding 7 \
-matching fuzzy \
-bw 0 \
-padding 0 \
-separator-style none \
-hide-scrollbar \
-line-margin 0 \
