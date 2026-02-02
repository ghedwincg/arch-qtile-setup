#!/bin/bash
# Arch Linux installation script with GRUB, 4 partitions, swap, microcode, and NetworkManager
#
# IMPORTANT:
# - Partition creation/formatting is the same for UEFI and BIOS.
# - The only difference is GRUB installation:
#     UEFI: grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
#     BIOS: grub-install --target=i386-pc $DISK
#
# Adjust these variables to match your disk setup

DISK="/dev/sda"
EFI="${DISK}1"
ROOT="${DISK}2"
HOME="${DISK}3"
DEVS="${DISK}4"
SWAP="${DISK}5"
HOSTNAME="archbox"
USERNAME="user"

echo ">>> Starting Arch installation..."

# 1. Sync clock
timedatectl set-ntp true

# 2. Initialize pacman keys
pacman-key --init
pacman-key --populate archlinux

# 3. Format partitions
# Same for UEFI and BIOS
mkfs.fat -F32 $EFI
mkfs.ext4 $ROOT
mkfs.ext4 $HOME
mkfs.ext4 $DEVS
mkswap $SWAP

# 4. Mount partitions
mount $ROOT /mnt
mkdir /mnt/boot
mount $EFI /mnt/boot
mkdir /mnt/home
mount $HOME /mnt/home
mkdir /mnt/devs
mount $DEVS /mnt/devs
swapon $SWAP

# 5. Install base system + essentials
# Add intel-ucode or amd-ucode depending on CPU
pacstrap /mnt base linux linux-firmware vim nano grub efibootmgr networkmanager intel-ucode

# 6. Generate fstab (including swap)
genfstab -U /mnt >> /mnt/etc/fstab
echo "$SWAP none swap defaults 0 0" >> /mnt/etc/fstab

# 7. Chroot into system
arch-chroot /mnt /bin/bash <<EOF
# Timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime
hwclock --systohc

# Localization
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOL
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOL

# Root password
echo ">>> Set root password:"
passwd

# GRUB installation
# UEFI:
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
# BIOS (Legacy boot):
# grub-install --target=i386-pc $DISK

grub-mkconfig -o /boot/grub/grub.cfg

# Create user
useradd -m -G wheel -s /bin/bash $USERNAME
echo ">>> Set password for $USERNAME:"
passwd $USERNAME

# Sudo access
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# Enable services
systemctl enable NetworkManager
EOF

# 8. Unmount partitions
swapoff $SWAP
umount -R /mnt

echo "✅ Installation complete. Reboot into your new Arch system."
