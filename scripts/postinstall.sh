#!/bin/bash
set -e

# Helpers
function trace { echo " -  $@"; }
function info { echo "[+] $@"; }

# Configure initramfs
info "Configuring initramfs"
sed -i '/^MODULES=()/ s/()/(btrfs)/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=(/ s/filesystems/encrypt &/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=(/ s/\s*fsck//' /etc/mkinitcpio.conf
mkinitcpio -p linux

# Create bootloader entry
info "Creating bootloader entry"
CRYPTDEVICE_UUID=$(lsblk -o PARTLABEL,UUID | awk '/cryptroot/{print $2}')
EFIDEVICE_PATH=$(lsblk -o PATH,TYPE,PARTLABEL | awk '/EFI/{print a}{a=$1}')
trace "Using device with UUID=$CRYPTDEVICE_UUID as cryptdevice"
efibootmgr --disk $EFIDEVICE_PATH --part 1 --create \
           --label "Arch Linux" \
           --loader /vmlinuz-linux \
           --unicode "cryptdevice=UUID=$CRYPTDEVICE_UUID:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw add_efi_memmap initrd=\initramfs-linux.img" \
           --verbose
