#!/usr/bin/env bash
# qtilesys setup for Arch + Qtile
# Copies configs into ~/.config and runs scripts with error logging

BASE_DIR="$HOME/qtilesys"
LOG_FILE="$BASE_DIR/install.log"

mkdir -p "$BASE_DIR"
: > "$LOG_FILE"

echo "=== Starting qtilesys setup at $(date) ===" | tee -a "$LOG_FILE"

copy_config() {
    local src="$1"
    local dest="$2"
    mkdir -p "$(dirname "$dest")"
    cp -f "$src" "$dest" >>"$LOG_FILE" 2>&1 || echo "ERROR copying $src" | tee -a "$LOG_FILE"
}

run_script() {
    local script="$1"
    if [[ -x "$script" ]]; then
        echo "--- Running $script ---" | tee -a "$LOG_FILE"
        "$script" >>"$LOG_FILE" 2>&1 || echo "ERROR in $script (see log)" | tee -a "$LOG_FILE"
    else
        echo "Skipping $script (not executable)" | tee -a "$LOG_FILE"
    fi
}

### Copy configs into ~/.config
copy_config "$BASE_DIR/dunst/dunstrc" "$HOME/.config/dunst/dunstrc"
copy_config "$BASE_DIR/picom/picom.conf" "$HOME/.config/picom/picom.conf"
copy_config "$BASE_DIR/qtile/config.py" "$HOME/.config/qtile/config.py"
copy_config "$BASE_DIR/Rofi/config.rasi" "$HOME/.config/rofi/config.rasi"
copy_config "$BASE_DIR/Rofi/notification_sidebar.rasi" "$HOME/.config/rofi/notification_sidebar.rasi"
copy_config "$BASE_DIR/Rofi/theme-minimal.rasi" "$HOME/.config/rofi/theme-minimal.rasi"
copy_config "$BASE_DIR/Rofi/Powermenu/powermenu.rasi" "$HOME/.config/rofi/powermenu.rasi"
copy_config "$BASE_DIR/Rofi/Powermenu/powermenu-confirm.rasi" "$HOME/.config/rofi/powermenu-confirm.rasi"

### Copy Xorg-related configs
copy_config "$BASE_DIR/xorg/xinitrc" "$HOME/.xinitrc"
copy_config "$BASE_DIR/xorg/bashrc" "$HOME/.bashrc"
copy_config "$BASE_DIR/xorg/bash_profile" "$HOME/.bash_profile"

### Run bin scripts
for s in "$BASE_DIR/bin/"*.sh; do
    run_script "$s"
done

### Run autostart
run_script "$BASE_DIR/qtile/autostart.sh"

### Run Rofi install scripts
for s in "$BASE_DIR/Rofi/"*.sh "$BASE_DIR/Rofi/Powermenu/"*.sh; do
    [[ -f "$s" ]] && run_script "$s"
done

echo "=== Finished qtilesys setup at $(date) ===" | tee -a "$LOG_FILE"
echo "Logs saved to $LOG_FILE"
