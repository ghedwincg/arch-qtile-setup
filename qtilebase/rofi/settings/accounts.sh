#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Profiles
Cloud Sync
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Accounts & Sync")

case "$choice" in
    "Profiles")
        sub=$(echo -e "User Management\nRoles\nBack" | rofi -dmenu -p "Profiles")
        case "$sub" in
            "User Management") alacritty -e sudo useradd --help ;;
            "Roles") alacritty -e sudo visudo ;;
            "Back") $0 ;;
        esac ;;
    "Cloud Sync")
        sub=$(echo -e "Rclone Mounts\nBack" | rofi -dmenu -p "Cloud")
        case "$sub" in
            "Rclone Mounts") alacritty -e rclone config ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Accounts & Sync only
        options="\
Accounts → Profiles → User Management
Accounts → Profiles → Roles
Accounts → Cloud → Rclone Mounts
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Accounts")

        case "$choice" in
            *"User Management") alacritty -e sudo useradd --help ;;
            *"Roles") alacritty -e sudo visudo ;;
            *"Rclone Mounts") alacritty -e rclone config ;;
            "Back") $0 ;;
        esac ;;
esac
