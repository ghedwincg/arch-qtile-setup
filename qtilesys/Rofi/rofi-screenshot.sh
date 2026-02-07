#!/usr/bin/env bash

###############################################################################
# ROFI SCREENSHOT MENU
###############################################################################

# Options
screen="  Fullscreen"
area="  Area"
window="  Window"
delay5="  Delay 5s"
delay10="  Delay 10s"

# Screenshot directory
screenshot_dir="$HOME/Pictures/Screenshots"
mkdir -p "$screenshot_dir"

# Filename
filename="${screenshot_dir}/screenshot_$(date +%Y%m%d_%H%M%S).png"

# Rofi CMD
rofi_cmd() {
    rofi -dmenu \
        -p "Screenshot" \
        -theme-str 'window {width: 400px; height: 300px;}' \
        -theme-str 'listview {columns: 1; lines: 5;}' \
        -theme-str 'element-text {horizontal-align: 0.5;}' \
        -theme-str 'inputbar {enabled: false;}'
}

# Pass variables to rofi dmenu
run_rofi() {
    echo -e "$screen\n$area\n$window\n$delay5\n$delay10" | rofi_cmd
}

# Screenshot functions
take_screenshot() {
    if command -v maim &> /dev/null; then
        case $1 in
            screen)
                maim "$filename"
                ;;
            area)
                maim -s "$filename"
                ;;
            window)
                maim -i "$(xdotool getactivewindow)" "$filename"
                ;;
            delay5)
                sleep 5 && maim "$filename"
                ;;
            delay10)
                sleep 10 && maim "$filename"
                ;;
        esac
    elif command -v scrot &> /dev/null; then
        case $1 in
            screen)
                scrot "$filename"
                ;;
            area)
                scrot -s "$filename"
                ;;
            window)
                scrot -u "$filename"
                ;;
            delay5)
                scrot -d 5 "$filename"
                ;;
            delay10)
                scrot -d 10 "$filename"
                ;;
        esac
    elif command -v flameshot &> /dev/null; then
        case $1 in
            screen)
                flameshot full -p "$screenshot_dir"
                return
                ;;
            area)
                flameshot gui -p "$screenshot_dir"
                return
                ;;
            window)
                flameshot screen -p "$screenshot_dir"
                return
                ;;
            delay5)
                flameshot full -d 5000 -p "$screenshot_dir"
                return
                ;;
            delay10)
                flameshot full -d 10000 -p "$screenshot_dir"
                return
                ;;
        esac
    else
        notify-send "Error" "No screenshot tool found. Install: maim, scrot, or flameshot"
        exit 1
    fi
    
    # Copy to clipboard and notify
    if [[ -f "$filename" ]]; then
        xclip -selection clipboard -t image/png -i "$filename"
        notify-send "Screenshot" "Saved and copied to clipboard\n$filename" -i "$filename"
    fi
}

# Execute
chosen="$(run_rofi)"
case ${chosen} in
    $screen)
        take_screenshot screen
        ;;
    $area)
        take_screenshot area
        ;;
    $window)
        take_screenshot window
        ;;
    $delay5)
        notify-send "Screenshot" "Taking screenshot in 5 seconds..."
        take_screenshot delay5
        ;;
    $delay10)
        notify-send "Screenshot" "Taking screenshot in 10 seconds..."
        take_screenshot delay10
        ;;
esac
