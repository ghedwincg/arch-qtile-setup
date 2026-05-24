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

#!/bin/bash
set -euo pipefail

# Log everything to /install.log
LOGFILE="/install.log"
exec > >(tee -a "$LOGFILE") 2>&1

# Disk layout
DISK="/dev/sda"
EFI="${DISK}1"
ROOT="${DISK}2"
HOME="${DISK}3"
#DEVS="${DISK}4"
#SWAP="${DISK}5"

# System identity
HOSTNAME="archbox"
USERNAME="user"

echo ">>> Starting Arch installation..."

# 1. Sync clock
timedatectl set-ntp true || echo "✘ Failed to sync clock"

# 2. Initialize pacman keys
pacman-key --init || echo "✘ Failed to init pacman keys"
pacman-key --populate archlinux || echo "✘ Failed to populate pacman keys"

# 3. Format partitions
mkfs.fat -F32 $EFI || echo "✘ Failed to format EFI"
mkfs.ext4 $ROOT || echo "✘ Failed to format ROOT"
mkfs.ext4 $HOME || echo "✘ Failed to format HOME"
#mkfs.ext4 $DEVS || echo "✘ Failed to format DEVS"
#mkswap $SWAP || echo "✘ Failed to format SWAP"

# 4. Mount partitions
mount $ROOT /mnt || echo "✘ Failed to mount ROOT"
mkdir -p /mnt/boot && mount $EFI /mnt/boot || echo "✘ Failed to mount EFI"
mkdir -p /mnt/home && mount $HOME /mnt/home || echo "✘ Failed to mount HOME"
#mkdir -p /mnt/devs && mount $DEVS /mnt/devs || echo "✘ Failed to mount DEVS"
#swapon $SWAP || echo "✘ Failed to enable SWAP"

# 5. Install base system
pacstrap /mnt base linux linux-firmware vim nano grub efibootmgr networkmanager amd-ucode || echo "✘ Pacstrap failed"

# 6. Generate fstab
genfstab -U /mnt >> /mnt/etc/fstab || echo "✘ Failed to generate fstab"
#echo "$SWAP none swap defaults 0 0" >> /mnt/etc/fstab

# 7. Configure system inside chroot
arch-chroot /mnt /bin/bash <<EOF
set -euo pipefail

echo ">>> Configuring system inside chroot..."

# Timezone & clock
ln -sf /usr/share/zoneinfo/UTC /etc/localtime || echo "✘ Failed timezone setup"
hwclock --systohc || echo "✘ Failed hwclock"

# Locale
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen || echo "✘ Failed locale-gen"
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Hostname
echo "$HOSTNAME" > /etc/hostname
cat > /etc/hosts <<EOL
127.0.0.1   localhost
::1         localhost
127.0.1.1   $HOSTNAME.localdomain $HOSTNAME
EOL

# Create user (no password yet)
useradd -m -G wheel -s /bin/bash $USERNAME || echo "✘ Failed to create user"

# Sudo access
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

# GRUB install (UEFI)
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB || echo "✘ Failed grub-install"
grub-mkconfig -o /boot/grub/grub.cfg || echo "✘ Failed grub-mkconfig"

# Enable services
systemctl enable NetworkManager || echo "✘ Failed to enable NetworkManager"

EOF

echo "✅ Installation complete."
echo "⚠️ IMPORTANT: Before reboot, you must set passwords!"
echo "Steps:"
echo "  1. arch-chroot /mnt"
echo "  2. passwd              # set root password"
echo "  3. passwd $USERNAME   # set user password"
echo "  4. exit"
echo "  5. umount -R /mnt" # run $SWAP && umount -R /mnt" if install swap
echo "  6. reboot"
echo "📄 Full log saved at $LOGFILE" # less /install.log to see log file
