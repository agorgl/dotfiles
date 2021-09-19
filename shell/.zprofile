#!/bin/zsh

# Autostart X
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -keeptty &> /dev/null
