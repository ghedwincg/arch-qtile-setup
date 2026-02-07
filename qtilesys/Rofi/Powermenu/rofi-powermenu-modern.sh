#!/usr/bin/env bash

###############################################################################
# ROFI POWER MENU - Modern Style with Confirmation Dialog
# Tailored for Arch + Qtile + Betterlockscreen + Pipewire
###############################################################################

# Theme files
THEME="$HOME/.config/rofi/themes/powermenu.rasi"
CONFIRM_THEME="$HOME/.config/rofi/themes/powermenu-confirm.rasi"

# Options with labels/icons
shutdown="⏻  Shutdown"
reboot="🔄  Reboot"
lock="🔒  Lock"
suspend="⏾  Suspend"
logout="🚪  Logout"

# Get system uptime
uptime_info=$(uptime -p | sed 's/up //')

# Confirmation dialog
confirm_exit() {
    local message="$1"
    rofi -dmenu \
        -p "$message" \
        -mesg "Are you sure?" \
        -theme "$CONFIRM_THEME" \
        -hover-select \
        -kb-cancel "Escape" \
        -click-to-exit <<< $'Yes\nNo'
}

# Show main menu
show_menu() {
    rofi -dmenu \
        -p "Uptime: $uptime_info" \
        -theme "$THEME" \
        -hover-select \
        -kb-cancel "Escape" \
        -click-to-exit <<< $''"$lock"$'\n'"$logout"$'\n'"$suspend"$'\n'"$reboot"$'\n'"$shutdown"
}

# Ensure theme exists
if [[ ! -f "$THEME" ]]; then
    echo "Theme file not found: $THEME"
    exit 1
fi

# Main loop
while true; do
    chosen=$(show_menu)
    [[ -z "$chosen" ]] && break

    case "$chosen" in
        "$lock")
            if command -v betterlockscreen &>/dev/null; then
                betterlockscreen -l
            elif command -v i3lock &>/dev/null; then
                i3lock -c 000000
            else
                notify-send "Lock Screen" "No lock screen program found"
            fi
            exit 0
            ;;
        "$logout")
            ans=$(confirm_exit "Logout")
            [[ "$ans" == "Yes" ]] && qtile cmd-obj -o cmd -f shutdown && exit 0
            ;;
        "$reboot")
            ans=$(confirm_exit "Reboot")
            [[ "$ans" == "Yes" ]] && systemctl reboot && exit 0
            ;;
        "$shutdown")
            ans=$(confirm_exit "Shutdown")
            [[ "$ans" == "Yes" ]] && systemctl poweroff && exit 0
            ;;
        "$suspend")
            ans=$(confirm_exit "Suspend")
            [[ "$ans" == "Yes" ]] && systemctl suspend && exit 0
            ;;
        *)
            break
            ;;
    esac
done
