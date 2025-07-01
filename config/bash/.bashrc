#
# bash/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Prompt
PS1='[\u@\h \W]\$ '

# History
HISTSIZE=5000
HISTFILESIZE=$HISTSIZE

# Interactive
[[ -f ~/.config/shell/interactive ]] && . ~/.config/shell/interactive
