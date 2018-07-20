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

function msg
{
    echo -e "$COL_TEXT$1$COL_RESET"
}

# Update
msg "Updating system..."
sudo pacman -Syyu

# Install git
msg "Installing git..."
sudo pacman -S --noconfirm git

# Clone my dots
cd
msg "Cloning dotfiles..."
git clone https://github.com/ElArtista/dotfiles .dot/dotfiles

# Install official packages
msg "Bootstraping packages..."
sudo pacman -S --needed $(cat .dot/dotfiles/misc/.misc/list.txt | sed '/nvidia.*/d' | tr "\n" " ")

# Install VM stuff
msg "Installing VM modules"
sudo pacman -S xf86-input-vmmouse xf86-video-vmware

# Install aur helper
~/.dot/dotfiles/scripts/.scripts/aurman.sh

# Install aur packages
msg "Installing aur packages..."
aurman -S --needed --noconfirm --noedit $(cat .dot/dotfiles/misc/.misc/list-aur.txt | tr "\n" " ")

# Move the relevant dotfiles in their place
msg "Bootstraping dotfiles..."
cd
rm -rf .bash*
cd .dot/dotfiles/
stow -t ../../.. *
cd ..

# Install open-vm-tools
msg "Installing open-vm-tools..."
sudo pacman -S open-vm-tools
sudo systemctl enable vmtoolsd.service
sudo systemctl start vmtoolsd.service

# Prepare Workdir
msg "Preparing Workdir..."
mkdir Workdir
cd Workdir/
sudo pacman -S mesa-libgl mesa-demos

# Finish
msg "Done."
