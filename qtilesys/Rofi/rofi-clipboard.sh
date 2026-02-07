#!/usr/bin/env bash

###############################################################################
# ROFI CLIPBOARD MANAGER - Tailored for CopyQ
###############################################################################

# Check if CopyQ is installed
if command -v copyq &> /dev/null; then
    # Show CopyQ history in Rofi
    copyq eval -- "for(i=0;i<size();++i) print(str(i)+': '+str(read(i))+'\n')" \
        | rofi -dmenu \
            -p "Clipboard (CopyQ)" \
            -theme-str 'window {width: 800px; height: 500px;}' \
            -theme-str 'listview {columns: 1; lines: 15;}' \
            -theme-str 'element-text {horizontal-align: 0.0;}'
else
    notify-send "Clipboard Manager" "CopyQ is not installed. Please install it with: sudo pacman -S copyq"
fi
