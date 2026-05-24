#!/bin/bash
# Usage: ./theme_switch.sh ~/Pictures/Wallpapers/image.jpg

# 1. Generate the color palette
wal -i "$1" -n --backend colorthief

# 2. Set the wallpaper (X11)
feh --bg-fill "$1"

# 3. Update Dunst (Notifications)
pkill dunst
dunst -config ~/.config/dunst/dunstrc &
