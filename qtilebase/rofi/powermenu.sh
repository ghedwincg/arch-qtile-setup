#!/usr/bin/env bash

# Get pywal colors
WAL_COLORS="$HOME/.cache/wal/colors.sh"
source "$WAL_COLORS" || exit 1

THEME="$HOME/.config/rofi/themes/powermenu.rasi"

# Icons for the main menu
options="\n\n\n\n"

confirm_exit() {
    echo -e "Yes\nNo" | rofi -dmenu -i \
        -p "Are you sure?" \
        -mesg "Are you sure you want to $1?" \
        -theme "$THEME" \
        -hover-select \
        -me-select-entry '' \
        -me-accept-entry MousePrimary \
        -click-to-exit
}

show_menu() {
    uptime_info=$(uptime -p)
    echo -e "$options" | rofi -dmenu -i \
        -p "System" \
        -mesg "$uptime_info" \
        -theme "$THEME" \
        -hover-select \
        -me-select-entry '' \
        -me-accept-entry MousePrimary \
        -click-to-exit
}

chosen=$(show_menu)

case "$chosen" in
    "") betterlockscreen -l ;;
    "") [[ $(confirm_exit "logout") == "Yes" ]] && qtile cmd-obj -o cmd -f shutdown ;;
    "") [[ $(confirm_exit "reboot") == "Yes" ]] && systemctl reboot ;;
    "") [[ $(confirm_exit "power off") == "Yes" ]] && systemctl poweroff ;;
    "") [[ $(confirm_exit "suspend") == "Yes" ]] && systemctl suspend ;;
esac
