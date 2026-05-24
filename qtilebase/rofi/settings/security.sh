#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Defense
Identity
Encryption
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Security")

case "$choice" in
    "Defense")
        sub=$(echo -e "Firewall\nSandboxing\nUSB Lockdown\nBack" | rofi -dmenu -p "Defense")
        case "$sub" in
            "Firewall") alacritty -e sudo ufw status ;;
            "Sandboxing") alacritty -e firejail --list ;;
            "USB Lockdown") alacritty -e sudo usbguard list-devices ;;
            "Back") $0 ;;
        esac ;;
    "Identity")
        sub=$(echo -e "Password Vault\nAuth Agent\nBack" | rofi -dmenu -p "Identity")
        case "$sub" in
            "Password Vault") keepassxc ;;
            "Auth Agent") rofi -e "Polkit agent runs automatically (polkit-gnome or polkit-kde)" ;;
            "Back") $0 ;;
        esac ;;
    "Encryption")
        sub=$(echo -e "Disk Encryption\nBack" | rofi -dmenu -p "Encryption")
        case "$sub" in
            "Disk Encryption") alacritty -e sudo cryptsetup status ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Security only
        options="\
Security → Defense → Firewall
Security → Defense → Sandboxing
Security → Defense → USB Lockdown
Security → Identity → Password Vault
Security → Identity → Auth Agent
Security → Encryption → Disk Encryption
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Security")

        case "$choice" in
            *"Firewall") alacritty -e sudo ufw status ;;
            *"Sandboxing") alacritty -e firejail --list ;;
            *"USB Lockdown") alacritty -e sudo usbguard list-devices ;;
            *"Password Vault") keepassxc ;;
            *"Auth Agent") rofi -e "Polkit agent runs automatically (polkit-gnome or polkit-kde)" ;;
            *"Disk Encryption") alacritty -e sudo cryptsetup status ;;
            "Back") $0 ;;
        esac ;;
esac
