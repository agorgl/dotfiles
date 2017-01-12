#
# ~/.bash_profile
#

[[ -f ~/.bashrc ]] && . ~/.bashrc
[[ -f ~/.profile ]] && . ~/.profile

# Autostart X
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -keeptty &> /dev/null
