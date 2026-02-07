#!/usr/bin/env bash

###############################################################################
# ROFI POWER MENU - INSTALLATION SCRIPT (Tailored for Arch + Qtile)
###############################################################################

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                                                               ║"
echo "║           ROFI POWER MENU - INSTALLATION                      ║"
echo "║                                                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Step 1: Create directories
echo "[1/3] Creating directories..."
mkdir -p ~/.config/rofi/themes
mkdir -p ~/.config/rofi/scripts
echo "✓ Directories created"
echo ""

# Step 2: Copy theme files
echo "[2/3] Installing theme files..."
if [[ -f "powermenu.rasi" ]]; then
    cp powermenu.rasi ~/.config/rofi/themes/
    echo "  ✓ powermenu.rasi installed"
fi
if [[ -f "powermenu-confirm.rasi" ]]; then
    cp powermenu-confirm.rasi ~/.config/rofi/themes/
    echo "  ✓ powermenu-confirm.rasi installed"
fi
echo "✓ Themes installed to ~/.config/rofi/themes/"
echo ""

# Step 3: Copy script and make executable
echo "[3/3] Installing power menu script..."
if [[ -f "rofi-powermenu-modern.sh" ]]; then
    cp rofi-powermenu-modern.sh ~/.config/rofi/scripts/rofi-powermenu.sh
    chmod +x ~/.config/rofi/scripts/rofi-powermenu.sh
    echo "✓ Script installed to ~/.config/rofi/scripts/rofi-powermenu.sh"
else
    echo "⚠ rofi-powermenu-modern.sh not found in current directory"
fi
echo ""

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║                    INSTALLATION COMPLETE                      ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Add to your Qtile config.py:"
echo ""
echo "  Key([mod], \"x\", lazy.spawn(\"~/.config/rofi/scripts/rofi-powermenu.sh\"),"
echo "      desc=\"Power menu\"),"
echo ""
echo "Or test it now:"
echo "  ~/.config/rofi/scripts/rofi-powermenu.sh"
echo ""
echo "═════════════════════════════════════════════════════════════════"
