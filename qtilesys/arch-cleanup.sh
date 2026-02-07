#!/usr/bin/env bash
# ============================================================
# Arch Linux Cleanup & Maintenance Script
# Author: LR (improved by Copilot)
# Purpose: Modular cleanup, optimization, and reporting
# ============================================================

LOG_DIR="$HOME/.local/share/maintenance-logs"
LOG_FILE="$LOG_DIR/arch-cleanup-$(date +%F).log"
mkdir -p "$LOG_DIR"

# --- Utility Functions ---
log() { echo "[INFO] $1" | tee -a "$LOG_FILE"; }
warn() { echo "[WARN] $1" | tee -a "$LOG_FILE"; }
error() { echo "[ERROR] $1" | tee -a "$LOG_FILE"; }
confirm() {
    read -rp "$1 [y/N]: " ans
    [[ "$ans" == "y" || "$ans" == "Y" ]]
}

# --- Cleanup Functions ---
clean_pkg_cache() {
    log "Cleaning package cache..."
    sudo paccache -rk3
}

remove_orphans() {
    log "Removing orphaned packages..."
    orphans=$(pacman -Qtdq)
    if [[ -n "$orphans" ]]; then
        sudo pacman -Rns $orphans
    else
        log "No orphaned packages found."
    fi
}

clean_logs() {
    log "Cleaning system logs..."
    sudo journalctl --vacuum-time=3d
}

clean_user_cache() {
    log "Cleaning user cache..."
    rm -rf ~/.cache/*
}

clean_old_kernels() {
    log "Removing old kernels..."
    sudo paccache -rk1
}

optimize_pacman_db() {
    log "Optimizing pacman database..."
    sudo pacman -D --asdeps $(pacman -Qdtq)
    sudo pacman -Scc --noconfirm
}

update_mirrors() {
    log "Updating mirror list..."
    sudo reflector --latest 20 --sort rate --save /etc/pacman.d/mirrorlist
}

rebuild_initramfs() {
    log "Rebuilding initramfs..."
    sudo mkinitcpio -P
}

system_health() {
    log "Checking system health..."
    systemctl --failed | tee -a "$LOG_FILE"
}

disk_report() {
    log "Disk usage report:"
    df -h | tee -a "$LOG_FILE"
}

rootkit_scan() {
    if confirm "Run rootkit scan (rkhunter)?"; then
        sudo rkhunter --update
        sudo rkhunter --check --sk
    fi
}

generate_report() {
    log "Generating system report..."
    echo "===== SYSTEM REPORT $(date) =====" >> "$LOG_FILE"
    uname -a >> "$LOG_FILE"
    df -h >> "$LOG_FILE"
    free -h >> "$LOG_FILE"
    systemctl --failed >> "$LOG_FILE"
    log "Report saved to $LOG_FILE"
}

# --- Full Cleanup ---
full_cleanup() {
    log "Starting full cleanup..."
    clean_pkg_cache
    remove_orphans
    clean_logs
    clean_user_cache
    clean_old_kernels
    optimize_pacman_db
    disk_report
    log "Full cleanup complete."
}

# --- Menu ---
menu() {
    echo "Arch Cleanup Menu"
    echo "1) Full system cleanup"
    echo "2) Clean package cache"
    echo "3) Remove orphaned packages"
    echo "4) Clean system logs"
    echo "5) Clean user cache"
    echo "6) Clean old kernels"
    echo "7) Optimize pacman database"
    echo "8) Update mirror list"
    echo "9) Rebuild initramfs"
    echo "10) Check system health"
    echo "11) Rootkit scan"
    echo "12) Generate system report"
    echo "0) Exit"
    read -rp "Choose option: " opt
    case $opt in
        1) full_cleanup ;;
        2) clean_pkg_cache ;;
        3) remove_orphans ;;
        4) clean_logs ;;
        5) clean_user_cache ;;
        6) clean_old_kernels ;;
        7) optimize_pacman_db ;;
        8) update_mirrors ;;
        9) rebuild_initramfs ;;
        10) system_health ;;
        11) rootkit_scan ;;
        12) generate_report ;;
        0) exit 0 ;;
        *) warn "Invalid option" ;;
    esac
}

# --- Flags ---
case "$1" in
    --full) full_cleanup ;;
    --report) generate_report ;;
    --health) system_health ;;
    --scan-rootkits) rootkit_scan ;;
    *) menu ;;
esac
