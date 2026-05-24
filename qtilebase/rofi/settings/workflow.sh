#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Terminal Suite
File Mastery
Interactions
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Workflow")

case "$choice" in
    "Terminal Suite")
        sub=$(echo -e "Emulator\nShell\nMultiplexer\nBack" | rofi -dmenu -p "Terminal")
        case "$sub" in
            "Emulator") alacritty ;;
            "Shell") alacritty -e zsh ;;
            "Multiplexer") alacritty -e tmux ;;
            "Back") $0 ;;
        esac ;;
    "File Mastery")
        sub=$(echo -e "Terminal FM\nPath Jumping\nSearch\nBack" | rofi -dmenu -p "Files")
        case "$sub" in
            "Terminal FM") alacritty -e yazi ;;
            "Path Jumping") alacritty -e zoxide ;;
            "Search") alacritty -e rg ;;
            "Back") $0 ;;
        esac ;;
    "Interactions")
        sub=$(echo -e "Launcher\nRemapping\nBack" | rofi -dmenu -p "Interactions")
        case "$sub" in
            "Launcher") rofi -show drun ;;
            "Remapping") alacritty -e input-remapper-gtk ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Workflow only
        options="\
Workflow → Terminal → Emulator
Workflow → Terminal → Shell
Workflow → Terminal → Multiplexer
Workflow → Files → Terminal FM
Workflow → Files → Path Jumping
Workflow → Files → Search
Workflow → Interactions → Launcher
Workflow → Interactions → Remapping
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Workflow")

        case "$choice" in
            *"Emulator") alacritty ;;
            *"Shell") alacritty -e zsh ;;
            *"Multiplexer") alacritty -e tmux ;;
            *"Terminal FM") alacritty -e yazi ;;
            *"Path Jumping") alacritty -e zoxide ;;
            *"Search") alacritty -e rg ;;
            *"Launcher") rofi -show drun ;;
            *"Remapping") alacritty -e input-remapper-gtk ;;
            "Back") $0 ;;
        esac ;;
esac
