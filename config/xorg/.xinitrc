#!/bin/sh

#
# xorg/.xinitrc
#

export WINDOW_MANAGER="$1"

if [ -d /etc/X11/xinit/xinitrc.d ]; then
    for f in /etc/X11/xinit/xinitrc.d/?*.sh; do
        [ -x "$f" ] && . "$f"
    done
    unset f
fi

xorg_dir="${XDG_CONFIG_HOME:-$HOME/.config}/xorg"
[ -f $xorg_dir/.Xresources ] && xrdb -merge $xorg_dir/.Xresources
[ -f $xorg_dir/.Xkbmap ] && setxkbmap `cat $xorg_dir/.Xkbmap`
[ -f $xorg_dir/.Xmodmap ] && xmodmap $xorg_dir/.Xmodmap
[ -f ~/.xprofile ] && . ~/.xprofile

exec "$WINDOW_MANAGER" "${@:2}"
