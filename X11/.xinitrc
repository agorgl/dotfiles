[ -f ~/.xprofile ] && . ~/.xprofile
sxhkd &
exec bspwm
