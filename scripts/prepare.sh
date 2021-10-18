#!/bin/bash
set -e

#
# Arguments
#
DRIVE=$1

#
# Constants
#
COMPRESS=zstd

#
# Helpers
#
info() { echo "[+] $@"; }
trace() { echo " -  $@"; }

#
# Setup functions
#
partition() {
    # Destroy GPT and MBR data structures
    trace "Destroying partition table"
    sgdisk --zap-all $DRIVE

    # Create GPT partition table
    sgdisk --clear $DRIVE

    # Create EFI partition
    trace "Creating EFI partition"
    sgdisk --new=1:0:+512MB --typecode=1:ef00 --change-name=1:EFI $DRIVE

    # Create root partition
    trace "Creating root partition"
    sgdisk --new=2:0:0 --typecode=2:8300 --change-name=2:cryptroot $DRIVE

    # Wait a bit for partitions to be ready
    sleep 2
}

encrypt() {
    # Encrypt partition
    trace "Encrypting root partition"
    cryptsetup luksFormat /dev/disk/by-partlabel/cryptroot

    # Open encrypted partition
    trace "Opening root partition"
    cryptsetup open /dev/disk/by-partlabel/cryptroot cryptroot
}

format() {
    # Format EFI partition
    trace "Formatting EFI partition"
    mkfs.vfat -F32 -n EFI /dev/disk/by-partlabel/EFI

    # Format root partition
    trace "Formatting root partition"
    mkfs.btrfs /dev/mapper/cryptroot

    # Create subvolumes
    trace "Creating subvolumes"
    mount -t btrfs -o compress=$COMPRESS /dev/mapper/cryptroot /mnt
    btrfs subvolume create /mnt/@
    btrfs subvolume create /mnt/@home
    btrfs subvolume create /mnt/@snapshots
    umount -R /mnt
}

mountp() {
    # Mount root partition
    trace "Mounting root partition"
    bp_opts=defaults,compress=$COMPRESS,noatime,space_cache=v2,discard=async
    mount -o $bp_opts,subvol=@ /dev/mapper/cryptroot /mnt

    # Create mountpoints
    trace "Creating mountpoints"
    mkdir -p /mnt/{boot,home,.snapshots}

    # Mount EFI partition
    info "Mounting EFI partition"
    mount /dev/disk/by-partlabel/EFI /mnt/boot

    # Mount remaining subvolumes
    info "Mounting remaining subvolumes"
    mount -o $bp_opts,subvol=@home /dev/mapper/cryptroot /mnt/home
    mount -o $bp_opts,subvol=@snapshots /dev/mapper/cryptroot /mnt/.snapshots
}

#
# Entrypoint
#
info "Partitioning drive $DRIVE"
partition

info "Encrypting partitions"
encrypt

info "Formatting partitions"
format

info "Mounting partitions"
mountp
