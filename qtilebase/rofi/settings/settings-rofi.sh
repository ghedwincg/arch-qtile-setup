#!/usr/bin/env bash

# Define the directory where all submenu scripts live
SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
1. System / General
2. Network & Connectivity
3. Display & Visuals
4. Privacy & Security
5. Powerful Workflow
6. Apps & Gaming
7. Intelligence & AI
8. Accounts & Sync
9. Accessibility
10. Infrastructure
Search
Exit
"

# Use Pywal colors for the main menu only 
choice=$(echo "$options" | rofi -dmenu \ 
    -p "Settings" \ 
    -theme ~/.cache/wal/colors-rofi-dark.rasi)

case "$choice" in
    "1. System / General") $SETTINGS_DIR/system.sh ;;
    "2. Network & Connectivity") $SETTINGS_DIR/network.sh ;;
    "3. Display & Visuals") $SETTINGS_DIR/display.sh ;;
    "4. Privacy & Security") $SETTINGS_DIR/security.sh ;;
    "5. Powerful Workflow") $SETTINGS_DIR/workflow.sh ;;
    "6. Apps & Gaming") $SETTINGS_DIR/apps.sh ;;
    "7. Intelligence & AI") $SETTINGS_DIR/ai.sh ;;
    "8. Accounts & Sync") $SETTINGS_DIR/accounts.sh ;;
    "9. Accessibility") $SETTINGS_DIR/accessibility.sh ;;
    "10. Infrastructure") $SETTINGS_DIR/infrastructure.sh ;;
    "Search") $SETTINGS_DIR/search.sh ;;
    "Exit") exit 0 ;;
esac
