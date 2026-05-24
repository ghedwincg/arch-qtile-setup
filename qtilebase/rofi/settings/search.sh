#!/usr/bin/env bash

# Define the directory where all submenu scripts live
SETTINGS_DIR="$HOME/.config/rofi/settings"

# Global search list (flattened tree of all categories and options)
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
Display → Qtile → Layout Engine
Display → Qtile → Keybindings
Display → Qtile → Decorations
Display → Graphics → Compositing/Blur
Display → Graphics → Layouts
Display → Graphics → Night Light
Display → Appearance → GTK/Icon Themes
Display → Appearance → Wallpaper
Privacy → Defense → Firewall
Privacy → Defense → Sandboxing
Privacy → Defense → USB Lockdown
Privacy → Identity → Password Vault
Privacy → Identity → Auth Agent
Privacy → Encryption → Disk Encryption
Workflow → Terminal → Emulator
Workflow → Terminal → Shell
Workflow → Terminal → Multiplexer
Workflow → Files → Terminal FM
Workflow → Files → Path Jumping
Workflow → Files → Search
Workflow → Interactions → Launcher
Workflow → Interactions → Remapping
Apps → Management → Installed Apps
Apps → Management → Default Apps
Apps → Performance → Game Tuning
Apps → Performance → HUD Overlay
AI → Engines → LLM Server
AI → Engines → Image Generation
AI → Workflow → AI Browser UI
AI → Workflow → Pattern Prompts
Accounts → Profiles → User Management
Accounts → Profiles → Roles
Accounts → Cloud → Rclone Mounts
Accessibility → Vision → Magnifier
Accessibility → Vision → High Contrast Themes
Accessibility → Input → Sticky Keys
Accessibility → Input → Mouse Sensitivity
Infrastructure → Hardware → SMART Diagnostics
Infrastructure → Hardware → Sensor Monitoring
Infrastructure → Drivers → Firmware
Infrastructure → Drivers → Graphics
Infrastructure → Logging → System Journal
Back
"

choice=$(echo "$options" | rofi -dmenu -p "Search Settings")

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
    *"Layout Engine") rofi -e "Edit ~/.config/qtile/config.py layouts" ;;
    *"Keybindings") rofi -e "Edit ~/.config/qtile/config.py keybindings" ;;
    *"Decorations") rofi -e "Qtile Extras active" ;;
    *"Compositing/Blur") alacritty -e picom --experimental-backends ;;
    *"Layouts") arandr ;;
    *"Night Light") alacritty -e redshift -O 3000 ;;
    *"GTK/Icon Themes") lxappearance ;;
    *"Wallpaper") nitrogen ;;
    *"Firewall") alacritty -e sudo ufw status ;;
    *"Sandboxing") alacritty -e firejail --list ;;
    *"USB Lockdown") alacritty -e sudo usbguard list-devices ;;
    *"Password Vault") keepassxc ;;
    *"Auth Agent") rofi -e "Polkit agent runs automatically" ;;
    *"Disk Encryption") alacritty -e sudo cryptsetup status ;;
    *"Emulator") alacritty ;;
    *"Shell") alacritty -e zsh ;;
    *"Multiplexer") alacritty -e tmux ;;
    *"Terminal FM") alacritty -e yazi ;;
    *"Path Jumping") alacritty -e zoxide ;;
    *"Search") alacritty -e rg ;;
    *"Launcher") rofi -show drun ;;
    *"Remapping") alacritty -e input-remapper-gtk ;;
    *"Installed Apps") alacritty -e pacman -Qe ;;
    *"Default Apps") alacritty -e mimeopen -d ;;
    *"Game Tuning") alacritty -e gamemode ;;
    *"HUD Overlay") alacritty -e mangohud ;;
    *"LLM Server") alacritty -e ollama run llama2 ;;
    *"Image Generation") alacritty -e ./stable-diffusion-webui/webui.sh ;;
    *"AI Browser UI") alacritty -e open-webui ;;
    *"Pattern Prompts") alacritty -e fabric ;;
    *"User Management") alacritty -e sudo useradd --help ;;
    *"Roles") alacritty -e sudo visudo ;;
    *"Rclone Mounts") alacritty -e rclone config ;;
    *"Magnifier") alacritty -e xzoom ;;
    *"High Contrast Themes") lxappearance ;;
    *"Sticky Keys") alacritty -e xset r rate 300 50 ;;
    *"Mouse Sensitivity") alacritty -e xset m 2 0 ;;
    *"SMART Diagnostics") alacritty -e sudo smartctl -a /dev/sda ;;
    *"Sensor Monitoring") alacritty -e sensors ;;
    *"Firmware") alacritty -e fwupdmgr get-updates ;;
    *"Graphics") rofi -e "Kernel Mode Setting is handled automatically" ;;
    *"System Journal") alacritty -e journalctl -xe ;;
    "Back") $SETTINGS_DIR/settings-rofi.sh ;;
esac
