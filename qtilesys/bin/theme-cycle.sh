#!/usr/bin/env bash
# Dynamic Wallpaper + Pywal + Dunst + Qtile
# chmod +x ~/bin/theme-cycle.sh
# Key([mod], "F11", lazy.spawn("~/.bin/theme-cycle.sh")),

# Cycles a random wallpaper and applies theme

set -euo pipefail

WALL_DIR="$HOME/Pictures/wallpapers"
CACHE_DIR="$HOME/.cache/wal"

# Ensure wallpaper directory exists
if [[ ! -d "$WALL_DIR" ]]; then
    echo "Wallpaper directory not found: $WALL_DIR"
    exit 1
fi

# Pick a random wallpaper (jpg/png)
wallpaper=$(find "$WALL_DIR" -type f \( -iname "*.jpg" -o -iname "*.png" \) | shuf -n 1)

if [[ -z "$wallpaper" ]]; then
    echo "No wallpapers found in $WALL_DIR"
    exit 1
fi

echo "[INFO] Applying wallpaper: $wallpaper"

# Generate Pywal colors
wal -i "$wallpaper" -q

# Update xrdb
xrdb -merge "$CACHE_DIR/colors.Xresources"

# Reload Dunst
if pgrep -x dunst >/dev/null; then
    pkill dunst
fi
dunst &

# Reload Qtile (bar + widgets pick up new colors)
if command -v qtile >/dev/null; then
    qtile cmd-obj -o cmd -f restart || true
fi

echo "[INFO] Theme applied successfully!"
echo "Colors: $CACHE_DIR/colors.json"
