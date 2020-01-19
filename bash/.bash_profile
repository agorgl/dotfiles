#
# ~/.bash_profile
#

[[ -f ~/.profile ]] && . ~/.profile
[[ -f ~/.bashrc ]] && . ~/.bashrc

# Autostart X
[[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && startx -- -keeptty &> /dev/null
