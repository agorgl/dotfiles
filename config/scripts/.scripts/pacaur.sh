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

function msg {
    echo -e "$COL_TEXT$1$COL_RESET"
}

# Install aur helper
msg "Installing aur helper..."
mkdir pacaur-tmp
cd pacaur-tmp/
wget http://aur.archlinux.org/cgit/aur.git/snapshot/cower.tar.gz
tar xzvf cower.tar.gz
cd cower
gpg --recv-keys --keyserver hkp://pgp.mit.edu 1EB2638FF56C0C53
makepkg
sudo pacman -U --noconfirm cower-*-x86_64.pkg.tar.xz
cd ..
wget http://aur.archlinux.org/cgit/aur.git/snapshot/pacaur.tar.gz
tar xzvf pacaur.tar.gz
cd pacaur
makepkg
sudo pacman -U --noconfirm pacaur-*-any.pkg.tar.xz
cd ../../..
rm -rf pacaur-tmp/

# Finish
msg "Done."
