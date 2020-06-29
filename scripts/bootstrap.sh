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

# Install git
msg "Installing git and stow..."
sudo pacman -S --noconfirm git stow

# Clone my dots
cd
msg "Cloning dotfiles..."
git clone https://github.com/ElArtista/dotfiles .dot/dotfiles

# Move the relevant dotfiles in their place
msg "Bootstraping dotfiles..."
cd
rm -rf .bash*
cd .dot/dotfiles/
stow -t ../../.. */
cd ..

# Update path
msg "Updating path..."
PATH=$PATH:$HOME/.scripts:$HOME/.bin

# Install official packages
msg "Bootstraping packages..."
sudo pacman -S --needed $(pkglist -n)

# Install aur helper
yay.sh

# Install aur packages
msg "Installing aur packages..."
yay -S --needed $(pkglist -m)

# Finish
msg "Done."
