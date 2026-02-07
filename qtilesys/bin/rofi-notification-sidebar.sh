#!/usr/bin/env bash
# Rofi Notification Sidebar

dunstctl history | rofi -dmenu \
    -p "Notifications" \
    -theme ~/.config/rofi/notification_sidebar.rasi
