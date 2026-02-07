#!/usr/bin/env bash

###############################################################################
# ROFI MASTER LAUNCHER - All-in-One Interface
# Tailored for LR's Arch + Qtile system (Flameshot + CopyQ + Pipewire)
# Launch with: rofi -show combi -config ~/.config/rofi/config.rasi
###############################################################################

ROFI_CONFIG="$HOME/.config/rofi/config.rasi"
SCRIPT_DIR="$HOME/.config/rofi/scripts"

# Main launcher - combi mode
launch_main() {
    rofi -show combi -config "$ROFI_CONFIG"
}

# Unified menu
launch_unified() {
    options=(
        "  Applications"
        "  Run Command"
        " 﩯 Windows"
        "  Files"
        "  Power Menu"
        "  Screenshot (Flameshot)"
        "  Network"
        "  Clipboard (CopyQ)"
        "  Settings"
        "  SSH Connections"
        "  Audio (Pipewire)"
    )
    
    choice=$(printf '%s\n' "${options[@]}" | rofi -dmenu -p "Quick Menu" \
        -config "$ROFI_CONFIG" \
        -theme-str 'window {width: 500px; height: 500px;}' \
        -theme-str 'listview {columns: 1; lines: 11;}')
    
    case "$choice" in
        "  Applications")
            rofi -show drun -config "$ROFI_CONFIG"
            ;;
        "  Run Command")
            rofi -show run -config "$ROFI_CONFIG"
            ;;
        " 﩯 Windows")
            rofi -show window -config "$ROFI_CONFIG"
            ;;
        "  Files")
            rofi -show filebrowser -config "$ROFI_CONFIG"
            ;;
        "  Power Menu")
            "$SCRIPT_DIR/rofi-power-menu.sh"
            ;;
        "  Screenshot (Flameshot)")
            flameshot gui
            ;;
        "  Network")
            "$SCRIPT_DIR/rofi-network.sh"
            ;;
        "  Clipboard (CopyQ)")
            copyq show
            ;;
        "  Settings")
            "$SCRIPT_DIR/rofi-settings.sh"
            ;;
        "  SSH Connections")
            rofi -show ssh -config "$ROFI_CONFIG"
            ;;
        "  Audio (Pipewire)")
            pavucontrol   # Pipewire uses pavucontrol for GUI control
            ;;
    esac
}

# Argument handling
case "${1:-}" in
    --unified|-u)
        launch_unified
        ;;
    --help|-h)
        echo "Rofi Master Launcher"
        echo "Usage: rofi-launcher [OPTION]"
        echo ""
        echo "Options:"
        echo "  (none)     Launch main combi interface (default)"
        echo "  -u, --unified    Launch unified menu"
        echo "  -h, --help       Show this help"
        ;;
    *)
        launch_main
        ;;
esac
