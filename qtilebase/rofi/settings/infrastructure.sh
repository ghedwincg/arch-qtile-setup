#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Hardware Health
Drivers
Logging
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Infrastructure")

case "$choice" in
    "Hardware Health")
        sub=$(echo -e "SMART Diagnostics\nSensor Monitoring\nBack" | rofi -dmenu -p "Hardware")
        case "$sub" in
            "SMART Diagnostics") alacritty -e sudo smartctl -a /dev/sda ;;
            "Sensor Monitoring") alacritty -e sensors ;;
            "Back") $0 ;;
        esac ;;
    "Drivers")
        sub=$(echo -e "Firmware\nGraphics\nBack" | rofi -dmenu -p "Drivers")
        case "$sub" in
            "Firmware") alacritty -e fwupdmgr get-updates ;;
            "Graphics") rofi -e "Kernel Mode Setting is handled automatically" ;;
            "Back") $0 ;;
        esac ;;
    "Logging")
        sub=$(echo -e "System Journal\nBack" | rofi -dmenu -p "Logging")
        case "$sub" in
            "System Journal") alacritty -e journalctl -xe ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Infrastructure only
        options="\
Infrastructure → Hardware → SMART Diagnostics
Infrastructure → Hardware → Sensor Monitoring
Infrastructure → Drivers → Firmware
Infrastructure → Drivers → Graphics
Infrastructure → Logging → System Journal
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Infrastructure")

        case "$choice" in
            *"SMART Diagnostics") alacritty -e sudo smartctl -a /dev/sda ;;
            *"Sensor Monitoring") alacritty -e sensors ;;
            *"Firmware") alacritty -e fwupdmgr get-updates ;;
            *"Graphics") rofi -e "Kernel Mode Setting is handled automatically" ;;
            *"System Journal") alacritty -e journalctl -xe ;;
            "Back") $0 ;;
        esac ;;
esac
