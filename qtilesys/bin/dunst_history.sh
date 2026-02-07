#!/usr/bin/env bash
# Simple script to show Dunst notification history in rofi

# Show history
dunstctl history | rofi -dmenu -p "Notifications"

# Clear history if needed
# dunstctl history-clear
