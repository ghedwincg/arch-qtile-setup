#!/usr/bin/env bash

###############################################################################
# ROFI POWER MENU - Tailored for Arch + Qtile + Pipewire + Betterlockscreen
###############################################################################

# Options
shutdown="⏻  Shutdown"
reboot="🔄  Reboot"
lock="🔒  Lock"
suspend="⏾  Suspend"
hibernate="💤  Hibernate"
logout="🚪  Logout"

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Power Menu" \
        -theme-str 'window {width: 400px; height: 350px;}' \
        -theme-str 'listview {columns: 1; lines: 6;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'inputbar {enabled: false;}'
}

# Confirmation CMD
confirm_cmd() {
    rofi -dmenu \
        -p "Are you sure?" \
        -theme-str 'window {width: 300px; height: 150px;}' \
        -theme-str 'listview {columns: 2; lines: 1;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'inputbar {enabled: false;}'
}

# Ask for confirmation
confirm_exit() {
    echo -e "Yes\nNo" | confirm_cmd
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$lock\n$suspend\n$logout\n$hibernate\n$reboot\n$shutdown" | rofi_cmd
}

# Execute Command
run_cmd() {
    selected="$(confirm_exit)"
    if [[ "$selected" == "Yes" ]]; then
        case "$1" in
            --shutdown) systemctl poweroff ;;
            --reboot) systemctl reboot ;;
            --suspend) systemctl suspend ;;
            --hibernate) systemctl hibernate ;;
            --logout) qtile cmd-obj -o cmd -f shutdown ;;
        esac
    else
        exit 0
    fi
}

# Actions
chosen="$(run_rofi)"
case ${chosen} in
    $shutdown)
        run_cmd --shutdown
        ;;
    $reboot)
        run_cmd --reboot
        ;;
    $lock)
        if command -v betterlockscreen &>/dev/null; then
            betterlockscreen -l
        elif command -v i3lock &>/dev/null; then
            i3lock -c 000000
        else
            echo "No lock screen found"
        fi
        ;;
    $suspend)
        run_cmd --suspend
        ;;
    $hibernate)
        run_cmd --hibernate
        ;;
    $logout)
        run_cmd --logout
        ;;
esac
