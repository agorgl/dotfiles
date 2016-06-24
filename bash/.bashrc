#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export HISTSIZE=3000
export EDITOR=vim
export PATH=$PATH:$HOME/.cabal/bin
export ANDROID_HOME=/opt/android-sdk-linux
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
