#!/usr/bin/env bash
# ROFI ADVANCED SETUP - Tailored for Arch + Qtile + Dunst
# Adapted for LR's system (Flameshot + CopyQ + Pipewire only)

set -euo pipefail

echo "=========================================="
echo "  ROFI ADVANCED CONFIGURATION INSTALLER"
echo "=========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Ensure Arch Linux
if [[ ! -f /etc/arch-release ]]; then
    echo -e "${YELLOW}Warning: This script is designed for Arch Linux${NC}"
    read -rp "Continue anyway? (y/n) " choice
    [[ "$choice" =~ ^[Yy]$ ]] || exit 1
fi

# Core packages (adapted to your system)
packages=(
    "rofi"
    "papirus-icon-theme"
    "ttf-jetbrains-mono-nerd"
    "flameshot"     # Screenshot tool
    "copyq"         # Clipboard manager
    "pipewire"      # Audio backend
    "pipewire-pulse"
    "pipewire-alsa"
    "pipewire-jack"
    "dunst"         # Notifications
    "picom"         # Compositor
    "networkmanager"
)

echo -e "${GREEN}[1/3] Installing required packages...${NC}"
for pkg in "${packages[@]}"; do
    if ! pacman -Qi "$pkg" &>/dev/null; then
        echo "  Installing $pkg..."
        sudo pacman -S --noconfirm "$pkg"
    else
        echo "  ✓ $pkg already installed"
    fi
done

# Directory structure
echo -e "${GREEN}[2/3] Creating directory structure...${NC}"
mkdir -p ~/.config/rofi/{themes,scripts}
mkdir -p ~/Pictures/Screenshots

# Copy configs (if provided in same dir)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$SCRIPT_DIR/config.rasi" ]]; then
    cp "$SCRIPT_DIR/config.rasi" ~/.config/rofi/config.rasi
    echo "  ✓ Main config installed"
fi

scripts=(
    "rofi-launcher.sh"
    "rofi-power-menu.sh"
    "rofi-clipboard.sh"
    "rofi-screenshot.sh"
    "rofi-network.sh"
    "rofi-settings.sh"
)

for script in "${scripts[@]}"; do
    if [[ -f "$SCRIPT_DIR/$script" ]]; then
        cp "$SCRIPT_DIR/$script" ~/.config/rofi/scripts/
        chmod +x ~/.config/rofi/scripts/"$script"
        echo "  ✓ $script installed"
    fi
done

# Qtile integration (instructions only)
echo -e "${GREEN}[3/3] Qtile Integration Setup${NC}"
cat << 'EOF'

Add to ~/.config/qtile/config.py:

from libqtile.config import Key
from libqtile.lazy import lazy

keys.extend([
    Key([mod], "space", lazy.spawn("rofi -show combi"), desc="Rofi launcher"),
    Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Applications"),
    Key([mod], "w", lazy.spawn("rofi -show window"), desc="Window switcher"),
    Key([mod], "e", lazy.spawn("rofi -show filebrowser"), desc="File browser"),
    Key([mod], "x", lazy.spawn("~/.config/rofi/scripts/rofi-power-menu.sh"), desc="Power menu"),
    Key([mod], "v", lazy.spawn("~/.config/rofi/scripts/rofi-clipboard.sh"), desc="Clipboard (CopyQ)"),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Screenshot (Flameshot)"),
    Key([mod], "n", lazy.spawn("~/.config/rofi/scripts/rofi-network.sh"), desc="Network"),
    Key([mod, "shift"], "s", lazy.spawn("~/.config/rofi/scripts/rofi-settings.sh"), desc="Settings"),
    Key([mod], "c", lazy.spawn("rofi -show calc -modi calc"), desc="Calculator"),
    Key([mod], "period", lazy.spawn("rofi -show emoji -modi emoji"), desc="Emoji picker"),
])
EOF

echo ""
echo "=========================================="
echo "  INSTALLATION COMPLETE"
echo "=========================================="
echo "Rofi is now set up with themes, scripts, and Qtile integration."
echo "Clipboard: CopyQ, Screenshots: Flameshot, Audio: Pipewire"
