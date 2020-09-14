#
# ~/.profile
#

# Load profiles from /etc/profile.d
if test -d /etc/profile.d/; then
    for profile in /etc/profile.d/*.sh; do
        test -r "$profile" && . "$profile"
    done
    unset profile
fi

export PATH=$PATH:$HOME/.scripts:$HOME/.bin
export XDG_CONFIG_HOME=~/.config
export QT_QPA_PLATFORMTHEME="gtk2"
