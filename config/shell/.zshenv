#!/bin/zsh

# Terminal
export TERM=xterm-256color

# Editor
export EDITOR="nvim"
export VISUAL="nvim"

# History
export HISTFILE=~/.zhistory
export HISTSIZE=5000
export SAVEHIST=5000

# Path
export PATH=$PATH:$HOME/.scripts:$HOME/.bin:$HOME/.cargo/bin

# Misc
export XDG_CONFIG_HOME=~/.config
export QT_QPA_PLATFORMTHEME="qt6gtk2"

# Source .environment if exists
[[ -f ~/.environment ]] && . ~/.environment
