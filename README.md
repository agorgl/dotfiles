# dotfiles

## Setup

Follow the instructions to perform the basic (opinionated) Arch Linux installation.

1. Partition, encrypt, format, and mount the drive from the installation medium using prepare.sh script (replace /dev/sda with your drive):
```
./prepare.sh /dev/sda
```
2. Install system and perform basic configuration:
```
./install.sh
```
3. Configure initramfs to support encrypted btrfs root partition
```
sed -i '/^MODULES=()/ s/()/(btrfs)/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=(/ s/filesystems/encrypt &/' /etc/mkinitcpio.conf
sed -i '/^HOOKS=(/ s/\s*fsck//' /etc/mkinitcpio.conf
mkinitcpio -p linux
```
4. Add bootloader entry
```
CRYPTDEVICE_UUID=$(lsblk -o PARTLABEL,UUID | awk '/cryptroot/{print $2}')
efibootmgr --disk /dev/sda --part 1 --create \
           --label "Arch Linux" \
           --loader /vmlinuz-linux \
           --unicode "cryptdevice=UUID=$CRYPTDEVICE_UUID:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ rw add_efi_memmap initrd=\initramfs-linux.img" \
           --verbose
```
