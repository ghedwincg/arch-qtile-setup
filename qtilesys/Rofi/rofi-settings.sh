#!/usr/bin/env bash

###############################################################################
# ROFI SETTINGS MENU - Tailored for Arch + Qtile + Pipewire + Blueman + Picom
###############################################################################

# Options
display="🖥️  Display Settings"
audio="🔊  Audio Settings"
bluetooth="🔵  Bluetooth"
keyboard="⌨️  Keyboard Layout"
theme="🎨  Theme Selector"
appearance="🖌️  Appearance"
notifications="🔔  Notifications"
compositor="✨  Compositor Toggle"

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Settings" \
        -theme-str 'window {width: 500px; height: 400px;}' \
        -theme-str 'listview {columns: 1; lines: 8;}' \
        -theme-str 'element-text {horizontal-align: 0.0;}'
}

# Display settings
display_settings() {
    if command -v arandr &> /dev/null; then
        arandr &
    else
        notify-send "Display" "Use xrandr from terminal or install arandr"
    fi
}

# Audio settings (Pipewire → pavucontrol)
audio_settings() {
    if command -v pavucontrol &> /dev/null; then
        pavucontrol &
    else
        notify-send "Error" "No audio control tool found (install pavucontrol)"
    fi
}

# Bluetooth manager (Blueman)
bluetooth_manager() {
    if command -v blueman-manager &> /dev/null; then
        blueman-manager &
    else
        notify-send "Error" "Blueman not installed"
    fi
}

# Keyboard layout switcher
keyboard_layout() {
    layouts=("us" "es" "fr" "de")
    choice=$(printf '%s\n' "${layouts[@]}" | rofi -dmenu -p "Keyboard Layout" \
        -theme-str 'window {width: 300px;}')
    
    if [[ -n "$choice" ]]; then
        setxkbmap "$choice"
        notify-send "Keyboard" "Layout changed to: $choice"
    fi
}

# Theme selector
theme_selector() {
    themes_dir="$HOME/.config/rofi/themes"
    if [[ -d "$themes_dir" ]]; then
        theme=$(ls -1 "$themes_dir"/*.rasi 2>/dev/null | xargs -n 1 basename | rofi -dmenu -p "Select Theme")
        if [[ -n "$theme" ]]; then
            notify-send "Theme" "Selected: $theme\nRestart Rofi to apply"
        fi
    else
        notify-send "Themes" "No custom themes found in $themes_dir"
    fi
}

# Appearance settings
appearance_settings() {
    if command -v lxappearance &> /dev/null; then
        lxappearance &
    elif command -v qt5ct &> /dev/null; then
        qt5ct &
    else
        notify-send "Error" "No appearance manager found"
    fi
}

# Notification settings (Dunst toggle)
notification_settings() {
    if pgrep -x dunst > /dev/null; then
        if dunstctl is-paused | grep -q "true"; then
            dunstctl set-paused false
            notify-send "Notifications" "Enabled"
        else
            notify-send "Notifications" "Pausing after this message..."
            sleep 2
            dunstctl set-paused true
        fi
    else
        notify-send "Error" "Dunst is not running"
    fi
}

# Compositor toggle (Picom)
compositor_toggle() {
    if pgrep -x picom > /dev/null; then
        pkill picom
        notify-send "Compositor" "Picom disabled"
    else
        picom --experimental-backends -b
        notify-send "Compositor" "Picom enabled"
    fi
}

# Main menu
run_rofi() {
    echo -e "$display\n$audio\n$bluetooth\n$keyboard\n$theme\n$appearance\n$notifications\n$compositor" | rofi_cmd
}

# Execute
chosen="$(run_rofi)"
case ${chosen} in
    "$display") display_settings ;;
    "$audio") audio_settings ;;
    "$bluetooth") bluetooth_manager ;;
    "$keyboard") keyboard_layout ;;
    "$theme") theme_selector ;;
    "$appearance") appearance_settings ;;
    "$notifications") notification_settings ;;
    "$compositor") compositor_toggle ;;
esac
