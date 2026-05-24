#!/bin/bash
# rofi-dashboard.sh
# Dashboard with "Back" navigation

show_main_menu() {
    echo "Run Command"
    echo "System Info"
    echo "Shortcuts"
}

if [ -z "$1" ]; then
    show_main_menu
else
    case "$1" in
        "Run Command")
            echo "Back"
            echo "Type a command in terminal mode"
            ;;
        "System Info")
            uptime -p
            free -h | awk '/Mem:/ {print "Memory: " $3 "/" $2}'
            df -h / | awk 'NR==2 {print "Disk: " $3 "/" $2}'
            echo "Back"
            ;;
        "Shortcuts")
            echo "Lock Screen"
            echo "Logout"
            echo "Reboot"
            echo "Shutdown"
            echo "Clipboard"
            echo "Back"
            ;;
        "Back")
            show_main_menu
            ;;
        "Lock Screen") loginctl lock-session ;;
        "Logout")      loginctl terminate-session "$XDG_SESSION_ID" ;;
        "Reboot")      systemctl reboot ;;
        "Shutdown")    systemctl poweroff ;;
        "Clipboard")   xclip -o ;;
    esac
fi
