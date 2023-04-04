#!/bin/bash

# Ctrl+C trap
function ctrl_c {
    echo "Interrupt received! Exiting..."
    exit 1
}
trap ctrl_c INT

# Color constants
COL_RESET="\e[0m"
COL_TEXT="\e[1;36m"

function msg { echo -e "$COL_TEXT$1$COL_RESET"; }

# Update
msg "Updating system..."
sudo pacman -Syyu

# Install git and stow
if ! pacman -Qq git stow 2>&1 >/dev/null; then
    msg "Installing git and stow..."
    sudo pacman -S --noconfirm git stow
fi

# Setup dotfiles
if [ ! -d $HOME/.dot/files ]; then
    # Clone my dots
    cd
    msg "Cloning dotfiles..."
    git clone https://github.com/agorgl/dotfiles $HOME/.dot/files

    # Move the relevant dotfiles in their place
    msg "Bootstraping dotfiles..."
    cd
    rm -rf .bash*
    cd $HOME/.dot/files/config
    stow -t ../../.. */
    cd ../../..
fi

# Update path
msg "Updating path..."
PATH=$PATH:$HOME/.scripts:$HOME/.bin

# Install official packages
msg "Bootstraping packages..."
sudo pacman -S --needed $(pkglist -n)

# Install aur helper
AUR_HELPER=paru
if ! pacman -Qq $AUR_HELPER 2>&1 >/dev/null; then
    msg "Installing aur helper..."
    git clone https://aur.archlinux.org/$AUR_HELPER
    cd $AUR_HELPER && makepkg -s -i
    cd .. && rm -rf $AUR_HELPER/
fi

# Install aur packages
msg "Installing aur packages..."
$AUR_HELPER -S --needed $(pkglist -m)

# Finish
msg "Done."
