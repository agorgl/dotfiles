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
export QT_QPA_PLATFORMTHEME="gtk2"
export GPG_TTY=$(tty)

# Source .environment if exists
[[ -f ~/.environment ]] && . ~/.environment
