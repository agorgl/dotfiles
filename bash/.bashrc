#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTSIZE=3000
export EDITOR=vim
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

# Setup z
[[ -r "/usr/share/z/z.sh" ]] && source /usr/share/z/z.sh

# Disable STAHP combo
stty -ixon
