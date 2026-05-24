#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
About / System Info
Software Update
Power & Battery
Backup & Recovery
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "System")

case "$choice" in
    "About / System Info")
        sub=$(echo -e "Device name\nHardware Specs\nOS/Kernel version\nBack" | rofi -dmenu -p "About")
        case "$sub" in
            "Device name") hostnamectl ;;
            "Hardware Specs") fastfetch ;;
            "OS/Kernel version") uname -a | rofi -e ;;
            "Back") $0 ;;
        esac ;;
    "Software Update")
        sub=$(echo -e "Pacman/AUR Management\nUpdate History\nMirror Optimization\nBack" | rofi -dmenu -p "Update")
        case "$sub" in
            "Pacman/AUR Management") alacritty -e yay ;;
            "Update History") alacritty -e paclog-viewer ;;
            "Mirror Optimization") alacritty -e sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist ;;
            "Back") $0 ;;
        esac ;;
    "Power & Battery")
        sub=$(echo -e "Performance Governors\nSleep/Suspend Timers\nBattery Health Analytics\nBack" | rofi -dmenu -p "Power")
        case "$sub" in
            "Performance Governors") alacritty -e auto-cpufreq --live ;;
            "Sleep/Suspend Timers") alacritty -e systemctl status systemd-logind ;;
            "Battery Health Analytics") upower -i $(upower -e | grep BAT) | rofi -e ;;
            "Back") $0 ;;
        esac ;;
    "Backup & Recovery")
        sub=$(echo -e "System Snapshots\nPre-update Automation\nDisaster Recovery\nBack" | rofi -dmenu -p "Backup")
        case "$sub" in
            "System Snapshots") timeshift-gtk ;;
            "Pre-update Automation") rofi -e "Handled by timeshift-autosnap" ;;
            "Disaster Recovery") rofi -e "Accessible via GRUB menu" ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for System only
        options="\
System → About → Device name
System → About → Hardware Specs
System → About → OS/Kernel version
System → Software Update → Pacman/AUR Management
System → Software Update → Update History
System → Software Update → Mirror Optimization
System → Power → Performance Governors
System → Power → Sleep/Suspend Timers
System → Power → Battery Health Analytics
System → Backup → System Snapshots
System → Backup → Pre-update Automation
System → Backup → Disaster Recovery
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search System")

        case "$choice" in
            *"Device name") hostnamectl ;;
            *"Hardware Specs") fastfetch ;;
            *"OS/Kernel version") uname -a | rofi -e ;;
            *"Pacman/AUR Management") alacritty -e yay ;;
            *"Update History") alacritty -e paclog-viewer ;;
            *"Mirror Optimization") alacritty -e sudo reflector --latest 10 --sort rate --save /etc/pacman.d/mirrorlist ;;
            *"Performance Governors") alacritty -e auto-cpufreq --live ;;
            *"Sleep/Suspend Timers") alacritty -e systemctl status systemd-logind ;;
            *"Battery Health Analytics") upower -i $(upower -e | grep BAT) | rofi -e ;;
            *"System Snapshots") timeshift-gtk ;;
            *"Pre-update Automation") rofi -e "Handled by timeshift-autosnap" ;;
            *"Disaster Recovery") rofi -e "Accessible via GRUB menu" ;;
            "Back") $0 ;;
        esac ;;
esac
