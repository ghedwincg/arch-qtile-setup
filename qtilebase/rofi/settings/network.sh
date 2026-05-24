#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Wi-Fi
Ethernet
VPN & Proxy
Continuity
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Network")

case "$choice" in
    "Wi-Fi")
        sub=$(echo -e "Power Toggle\nSaved Networks\nHotspot Settings\nMAC Randomization\nBack" | rofi -dmenu -p "Wi-Fi")
        case "$sub" in
            "Power Toggle") nmcli radio wifi off && rofi -e "Wi-Fi Disabled" || nmcli radio wifi on && rofi -e "Wi-Fi Enabled" ;;
            "Saved Networks") nm-connection-editor ;;
            "Hotspot Settings") alacritty -e linux-wifi-hotspot ;;
            "MAC Randomization") rofi -e "Edit /etc/NetworkManager/NetworkManager.conf" ;;
            "Back") $0 ;;
        esac ;;
    "Ethernet")
        sub=$(echo -e "Interface Management\nIP Assignment\nHardware\nBack" | rofi -dmenu -p "Ethernet")
        case "$sub" in
            "Interface Management") nmcli device status | rofi -e ;;
            "IP Assignment") nm-connection-editor ;;
            "Hardware") rofi -e "Check Wake-on-LAN & 802.1X in nm-connection-editor" ;;
            "Back") $0 ;;
        esac ;;
    "VPN & Proxy")
        sub=$(echo -e "VPN Profiles\nProxy/DNS over HTTPS\nBack" | rofi -dmenu -p "VPN")
        case "$sub" in
            "VPN Profiles") nm-connection-editor ;;
            "Proxy/DNS over HTTPS") alacritty -e sudo systemctl restart dnscrypt-proxy ;;
            "Back") $0 ;;
        esac ;;
    "Continuity")
        sub=$(echo -e "Cross-device Clipboard\nNetwork Share\nBack" | rofi -dmenu -p "Continuity")
        case "$sub" in
            "Cross-device Clipboard") alacritty -e kdeconnect-indicator ;;
            "Network Share") alacritty -e sudo systemctl restart smb ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Network only
        options="\
Network → Wi-Fi → Power Toggle
Network → Wi-Fi → Saved Networks
Network → Wi-Fi → Hotspot Settings
Network → Wi-Fi → MAC Randomization
Network → Ethernet → Interface Management
Network → Ethernet → IP Assignment
Network → Ethernet → Hardware
Network → VPN → VPN Profiles
Network → VPN → Proxy/DNS over HTTPS
Network → Continuity → Cross-device Clipboard
Network → Continuity → Network Share
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Network")

        case "$choice" in
            *"Power Toggle") nmcli radio wifi off && rofi -e "Wi-Fi Disabled" || nmcli radio wifi on && rofi -e "Wi-Fi Enabled" ;;
            *"Saved Networks") nm-connection-editor ;;
            *"Hotspot Settings") alacritty -e linux-wifi-hotspot ;;
            *"MAC Randomization") rofi -e "Edit /etc/NetworkManager/NetworkManager.conf" ;;
            *"Interface Management") nmcli device status | rofi -e ;;
            *"IP Assignment") nm-connection-editor ;;
            *"Hardware") rofi -e "Check Wake-on-LAN & 802.1X in nm-connection-editor" ;;
            *"VPN Profiles") nm-connection-editor ;;
            *"Proxy/DNS over HTTPS") alacritty -e sudo systemctl restart dnscrypt-proxy ;;
            *"Cross-device Clipboard") alacritty -e kdeconnect-indicator ;;
            *"Network Share") alacritty -e sudo systemctl restart smb ;;
            "Back") $0 ;;
        esac ;;
esac
