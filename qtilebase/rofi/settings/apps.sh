#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Management
Performance
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Apps & Gaming")

case "$choice" in
    "Management")
        sub=$(echo -e "Installed Apps\nDefault Apps\nBack" | rofi -dmenu -p "Management")
        case "$sub" in
            "Installed Apps") alacritty -e pacman -Qe ;;
            "Default Apps") alacritty -e mimeopen -d ;;
            "Back") $0 ;;
        esac ;;
    "Performance")
        sub=$(echo -e "Game Tuning\nHUD Overlay\nBack" | rofi -dmenu -p "Performance")
        case "$sub" in
            "Game Tuning") alacritty -e gamemode ;;
            "HUD Overlay") alacritty -e mangohud ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Apps & Gaming only
        options="\
Apps → Management → Installed Apps
Apps → Management → Default Apps
Apps → Performance → Game Tuning
Apps → Performance → HUD Overlay
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Apps")

        case "$choice" in
            *"Installed Apps") alacritty -e pacman -Qe ;;
            *"Default Apps") alacritty -e mimeopen -d ;;
            *"Game Tuning") alacritty -e gamemode ;;
            *"HUD Overlay") alacritty -e mangohud ;;
            "Back") $0 ;;
        esac ;;
esac
