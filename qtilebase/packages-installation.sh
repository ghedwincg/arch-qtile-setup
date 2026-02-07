#!/bin/bash
################################################################################
# Arch + Qtile Workstation Installer
# Purpose: Install all required packages with error logging and update automation
################################################################################

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M")
ERROR_LOG="/tmp/install_errors_$TIMESTAMP.log"


print_section() { echo -e "\n${GREEN}▶ $1${NC}\n"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

confirm() {
    read -p "$(echo -e ${YELLOW}[?]${NC} $1 [y/N]: )" -n 1 -r; echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

safe_install() {
    local pkg="$1"
    local output

    # Try pacman first
    if output=$(sudo pacman -S --needed --noconfirm "$pkg" 2>&1); then
        print_success "Installed $pkg (official repo)"
    # If pacman fails, try yay
    elif output=$(yay -S --needed --noconfirm "$pkg" 2>&1); then
        print_success "Installed $pkg (AUR)"
    else
        # Check for specific error reasons
        if echo "$output" | grep -q "target not found"; then
            print_error "Package not found: $pkg"
            echo "$(date '+%F %T') - $pkg - NOT FOUND" >> "$ERROR_LOG"
        elif echo "$output" | grep -qi "conflict"; then
            print_error "Conflict installing: $pkg"
            echo "$(date '+%F %T') - $pkg - CONFLICT" >> "$ERROR_LOG"
        elif echo "$output" | grep -qi "failed to connect"; then
            print_error "Network error installing: $pkg"
            echo "$(date '+%F %T') - $pkg - NETWORK ERROR" >> "$ERROR_LOG"
        else
            print_error "Failed to install $pkg"
            # Log the first line of the error as reason
            local reason=$(echo "$output" | head -n 1)
            echo "$(date '+%F %T') - $pkg - $reason" >> "$ERROR_LOG"
        fi
    fi
}

###############################################################################
# INSTALL SECTIONS
###############################################################################

install_core() {
    print_section "Core System"
    local pkgs=(xorg-server xorg-xinit xorg-xrandr xorg-xsetroot qtile python-pip python-psutil python-dbus-next python-cairocffi python-requests archlinux-keyring pkgfile reflector)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_compositor() {
    print_section "Compositor"
    if confirm "Install picom with animations?"; then
        safe_install picom-jonaburg-git || safe_install picom
    else
        safe_install picom
    fi
}

install_terminals() {
    print_section "Terminals"
    local pkgs=(kitty alacritty zsh zsh-completions zsh-syntax-highlighting zsh-autosuggestions)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_launchers() {
    print_section "Launchers"
    local pkgs=(rofi dmenu)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_notifications() {
    print_section "Notifications"
    local pkgs=(dunst libnotify)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_file_management() {
    print_section "File Management"
    local pkgs=(dolphin chezmoi ark gvfs gvfs-mtp gvfs-gphoto2 gvfs-afc gvfs-smb gvfs-nfs tumbler ffmpegthumbnailer xdg-utils shared-mime-info desktop-file-utils xdg-desktop-portal xdg-desktop-portal-gtk)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_security() {
    print_section "Security"
    local pkgs=(ufw fail2ban polkit gnome-keyring rkhunter lynis firejail)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
    if confirm "Enable firewall (UFW)?"; then
        sudo systemctl enable ufw
        sudo ufw default deny incoming
        sudo ufw default allow outgoing
        sudo ufw enable
    fi
}

install_network() {
    print_section "Network"
    local pkgs=(networkmanager network-manager-applet nm-connection-editor networkmanager-openvpn wpa_supplicant)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
    sudo systemctl enable NetworkManager
}

install_bluetooth() {
    print_section "Bluetooth"
    local pkgs=(bluez bluez-utils blueman)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
    sudo systemctl enable bluetooth
}

install_audio() {
    print_section "Audio"
    local pkgs=(pipewire pipewire-alsa pipewire-pulse pipewire-jack pavucontrol playerctl alsa-utils wireplumber)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_power() {
    print_section "Power Management"
    local pkgs=(acpi acpid tlp powertop)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
    if confirm "Enable TLP?"; then sudo systemctl enable tlp; fi
}

install_display() {
    print_section "Display"
    local pkgs=(arandr autorandr brightnessctl redshift xdg-desktop-portal-gtk)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_fonts_icons() {
    print_section "Fonts & Icons"
    local pkgs=(ttf-jetbrains-mono-nerd ttf-font-awesome noto-fonts noto-fonts-emoji noto-fonts-cjk papirus-icon-theme)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_themes() {
    print_section "Themes"
    local pkgs=(lxappearance gtk3 gtk4 gtkmm3 gtkmm4 gnome-themes-extra arc-gtk-theme materia-gtk-theme pywal)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
    if confirm "Install Tokyo Night GTK theme?"; then
        git clone https://github.com/Fausto-Korpsvart/Tokyo-Night-GTK-Theme.git /tmp/Tokyo-Night-GTK-Theme
        sudo cp -r /tmp/Tokyo-Night-GTK-Theme/themes/Tokyonight-Dark-BL /usr/share/themes/
    fi
}

install_admin_tools() {
    print_section "Admin Tools"
    local pkgs=(btop gnome-system-monitor gnome-disk-utility gparted baobab gnome-logs dconf-editor)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_browsers() {
    print_section "Browsers"
    local pkgs=(firefox brave-bin)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_productivity() {
    print_section "Productivity"
    local pkgs=(libreoffice-fresh thunderbird gnome-calendar)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_development() {
    print_section "Development"
    if confirm "Install dev tools?"; then
        local pkgs=(git base-devel vim neovim code docker docker-compose podman)
        for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
        if confirm "Enable Docker?"; then sudo systemctl enable docker; sudo usermod -aG docker "$USER"; fi
    fi
}

install_multimedia() {
    print_section "Multimedia"
    local pkgs=(vlc mpv imagemagick feh gimp inkscape)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_cloud() {
    print_section "Cloud"
    if confirm "Install Nextcloudmousepad client?"; then safe_install nextcloud-client; fi
    if confirm "Install Dropbox?"; then safe_install dropbox; fi
}

install_backup() {
    print_section "Backup"
    local pkgs=(timeshift rsync timeshift-autosnap borg)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

install_utilities() {
    print_section "Utilities"
    local pkgs=(unzip unrar p7zip wget curl tree fastfetch lolcat cmatrix bat exa fd ripgrep fzf flameshot copyq zathura zathura-pdf-mupdf inxi)
    for pkg in "${pkgs[@]}"; do safe_install "$pkg"; done
}

###############################################################################
# MAIN FLOW
###############################################################################

main() {
    print_section "System Update"
    sudo pacman -Syu --noconfirm || echo "System update failed" >> "$ERROR_LOG"

    install_core
    install_compositor
    install_terminals
    install_launchers
    install_notifications
    install_file_management
    install_security
    install_network
    install_bluetooth
    install_audio
    install_power
    install_display
    install_fonts_icons
    install_themes
    install_admin_tools
    install_browsers
    install_productivity
    install_development
    install_multimedia
    install_cloud
    install_backup
    install_utilities

    print_section "SUMMARY"
    if [[ -s "$ERROR_LOG" ]]; then
        print_warning "Some packages failed:"
        cat "$ERROR_LOG"
    else
        print_success "All packages installed successfully!"
    fi
}

main "$@"
