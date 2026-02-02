#!/usr/bin/env bash

# Options with icons (using Font Awesome)
options=" \n \n \n \n "
  
# Theme file path
THEME="$HOME/.config/rofi/theme.rasi"

# Check if theme exists
if [ ! -f "$THEME" ]; then
    echo "Theme file not found: $THEME"
    echo "Please create the theme file first!"
    exit 1
fi

# Rofi command with theme file
chosen=$(echo -e "$options" | rofi -dmenu -i \
    -me-select-entry '' \
    -me-accept-entry MousePrimary \
    -hover-select \
    -theme "$THEME")
    
case "$chosen" in
    " ") betterlockscreen -l ;;
    " ") qtile cmd-obj -o cmd -f shutdown ;;
    " ") systemctl reboot ;;
    " ") systemctl poweroff ;;
    " ") systemctl suspend ;;
esac

