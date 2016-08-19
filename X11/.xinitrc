# Start system configuration
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
   for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
      [ -x "$f" ] && . "$f"
   done
   unset f
fi

# User programs
[ -f ~/.xprofile ] && . ~/.xprofile

# Window manager
sxhkd &
exec bspwm
