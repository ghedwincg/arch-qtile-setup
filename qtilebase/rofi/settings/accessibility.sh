#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Vision
Input
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Accessibility")

case "$choice" in
    "Vision")
        sub=$(echo -e "Magnifier\nHigh Contrast Themes\nBack" | rofi -dmenu -p "Vision")
        case "$sub" in
            "Magnifier") alacritty -e xzoom ;;
            "High Contrast Themes") lxappearance ;;
            "Back") $0 ;;
        esac ;;
    "Input")
        sub=$(echo -e "Sticky Keys\nMouse Sensitivity\nBack" | rofi -dmenu -p "Input")
        case "$sub" in
            "Sticky Keys") alacritty -e xset r rate 300 50 ;;
            "Mouse Sensitivity") alacritty -e xset m 2 0 ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Accessibility only
        options="\
Accessibility → Vision → Magnifier
Accessibility → Vision → High Contrast Themes
Accessibility → Input → Sticky Keys
Accessibility → Input → Mouse Sensitivity
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Accessibility")

        case "$choice" in
            *"Magnifier") alacritty -e xzoom ;;
            *"High Contrast Themes") lxappearance ;;
            *"Sticky Keys") alacritty -e xset r rate 300 50 ;;
            *"Mouse Sensitivity") alacritty -e xset m 2 0 ;;
            "Back") $0 ;;
        esac ;;
esac
