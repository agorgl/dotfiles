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
mkdir yay-tmp
cd yay-tmp/
curl https://aur.archlinux.org/cgit/aur.git/snapshot/yay.tar.gz | tar xzv
cd yay
makepkg -s -i
cd ../../..
rm -rf yay-tmp/

# Finish
msg "Done."
