#!/bin/bash
set -e

# Constants
INSTALL_BASE=/mnt
INSTALL_PKGS=(base linux linux-firmware sudo refind)

# Helpers
function trace { echo " -  $@"; }
function info { echo "[+] $@"; }

# Setup functions
function setup_host {
    trace "Ensuring the system clock is accurate"
    timedatectl set-ntp true

    trace "Installing essential packages"
    pacstrap $INSTALL_BASE --needed ${INSTALL_PKGS[@]}

    trace "Generating fstab file"
    genfstab -U $INSTALL_BASE >> $INSTALL_BASE/etc/fstab
}

function setup_guest {
    trace "Setting the time zone"
    ln -sf /usr/share/zoneinfo/Europe/Athens /etc/localtime

    trace "Generating /etc/adjtime"
    hwclock --systohc

    trace "Uncommenting en_US.UTF-8 UTF-8 locale"
    sed -i '/en_US.UTF-8/s/^#//' /etc/locale.gen

    trace "Generating the locales"
    locale-gen

    trace "Creating the locale.conf file and setting the LANG variable accordingly"
    echo LANG=en_US.UTF-8 > /etc/locale.conf

    trace "Setting the root password"
    passwd
}

# Check for root
if (($EUID != 0)); then
    echo "Must be run as root!"
    exit 1
fi

# Entrypoint
if [ ! -f "/opt/$(basename $0)" ]; then
    info "Setting up host"
    setup_host
    cp $0 "$INSTALL_BASE/opt/"

    trace "Changing root into the new system"
    arch-chroot $INSTALL_BASE /opt/$(basename $0)
else
    info "Setting up guest"
    setup_guest
fi
