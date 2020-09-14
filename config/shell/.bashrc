#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source .shrc file
[[ -f ~/.shrc ]] && . ~/.shrc

# Disable STAHP combo
stty -ixon
