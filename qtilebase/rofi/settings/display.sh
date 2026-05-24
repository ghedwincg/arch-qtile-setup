#!/usr/bin/env bash

SETTINGS_DIR="$HOME/.config/rofi/settings"

options="\
Qtile Window Manager
Graphics
Appearance
Back
Search
"

choice=$(echo "$options" | rofi -dmenu -p "Display")

case "$choice" in
    "Qtile Window Manager")
        sub=$(echo -e "Layout Engine\nKeybindings\nDecorations\nBack" | rofi -dmenu -p "Qtile")
        case "$sub" in
            "Layout Engine") rofi -e "Edit ~/.config/qtile/config.py layouts" ;;
            "Keybindings") rofi -e "Edit ~/.config/qtile/config.py keybindings" ;;
            "Decorations") rofi -e "Qtile Extras active" ;;
            "Back") $0 ;;
        esac ;;
    "Graphics")
        sub=$(echo -e "Compositing/Blur\nLayouts\nNight Light\nBack" | rofi -dmenu -p "Graphics")
        case "$sub" in
            "Compositing/Blur") alacritty -e picom --experimental-backends ;;
            "Layouts") arandr ;;
            "Night Light") alacritty -e redshift -O 3000 ;;
            "Back") $0 ;;
        esac ;;
    "Appearance")
        sub=$(echo -e "GTK/Icon Themes\nWallpaper\nBack" | rofi -dmenu -p "Appearance")
        case "$sub" in
            "GTK/Icon Themes") lxappearance ;;
            "Wallpaper") nitrogen ;;
            "Back") $0 ;;
        esac ;;
    "Back")
        $SETTINGS_DIR/settings-rofi.sh ;;
    "Search")
        # Local search list for Display only
        options="\
Display → Qtile → Layout Engine
Display → Qtile → Keybindings
Display → Qtile → Decorations
Display → Graphics → Compositing/Blur
Display → Graphics → Layouts
Display → Graphics → Night Light
Display → Appearance → GTK/Icon Themes
Display → Appearance → Wallpaper
Back
"

        choice=$(echo "$options" | rofi -dmenu -p "Search Display")

        case "$choice" in
            *"Layout Engine") rofi -e "Edit ~/.config/qtile/config.py layouts" ;;
            *"Keybindings") rofi -e "Edit ~/.config/qtile/config.py keybindings" ;;
            *"Decorations") rofi -e "Qtile Extras active" ;;
            *"Compositing/Blur") alacritty -e picom --experimental-backends ;;
            *"Layouts") arandr ;;
            *"Night Light") alacritty -e redshift -O 3000 ;;
            *"GTK/Icon Themes") lxappearance ;;
            *"Wallpaper") nitrogen ;;
            "Back") $0 ;;
        esac ;;
esac
