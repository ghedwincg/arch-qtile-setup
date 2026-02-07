#!/usr/bin/env bash
# ============================================================
# Automated Weekly Maintenance Script
# Author: LR (improved by Copilot)
# Purpose: Safe, modular weekly maintenance with logging
# ============================================================

# --- Colors ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Config ---
LOG_DIR="$HOME/.local/share/maintenance-logs"
LOG_FILE="$LOG_DIR/maintenance-$(date +%Y%m%d_%H%M%S).log"
KEEP_LOGS=10
mkdir -p "$LOG_DIR"

# --- Logging ---
log() { echo -e "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"; }

# --- Functions ---
check_updates() {
    log "${YELLOW}[1] Checking for updates...${NC}"
    sudo pacman -Sy >/dev/null 2>&1
    updates=$(pacman -Qu | wc -l)
    [[ $updates -gt 0 ]] && log "${YELLOW}Found $updates updates${NC}" || log "${GREEN}✓ System up to date${NC}"
}

clean_pkg_cache() {
    log "${YELLOW}[2] Cleaning package cache...${NC}"
    before=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | awk '{print $1}')
    log "Cache before: $before"
    if command -v paccache &>/dev/null; then
        sudo paccache -rk3 >>"$LOG_FILE" 2>&1
        sudo paccache -ruk0 >>"$LOG_FILE" 2>&1
        after=$(du -sh /var/cache/pacman/pkg/ 2>/dev/null | awk '{print $1}')
        log "Cache after: $after"
        log "${GREEN}✓ Package cache cleaned${NC}"
    else
        log "${RED}✗ paccache not found${NC}"
    fi
}

remove_orphans() {
    log "${YELLOW}[3] Removing orphaned packages...${NC}"
    orphans=$(pacman -Qtdq 2>/dev/null)
    [[ -n "$orphans" ]] && echo "$orphans" | xargs sudo pacman -Rns --noconfirm >>"$LOG_FILE" 2>&1 && log "${GREEN}✓ Orphans removed${NC}" || log "${GREEN}✓ No orphans${NC}"
}

clean_logs() {
    log "${YELLOW}[4] Cleaning system logs...${NC}"
    before=$(du -sh /var/log/ 2>/dev/null | awk '{print $1}')
    log "Logs before: $before"
    sudo journalctl --vacuum-time=7d >>"$LOG_FILE" 2>&1
    sudo journalctl --vacuum-size=100M >>"$LOG_FILE" 2>&1
    after=$(du -sh /var/log/ 2>/dev/null | awk '{print $1}')
    log "Logs after: $after"
    log "${GREEN}✓ Logs cleaned${NC}"
}

clean_user_cache() {
    log "${YELLOW}[5] Cleaning user cache...${NC}"
    before=$(du -sh ~/.cache 2>/dev/null | awk '{print $1}')
    rm -rf ~/.cache/thumbnails/* ~/.thumbnails/* ~/.local/share/Trash/* 2>/dev/null
    after=$(du -sh ~/.cache 2>/dev/null | awk '{print $1}')
    log "Cache before: $before | after: $after"
    log "${GREEN}✓ User cache cleaned${NC}"
}

system_health() {
    log "${YELLOW}[6] System health check...${NC}"
    df -h / /home | tee -a "$LOG_FILE"
    root_usage=$(df / | awk 'NR==2 {print $5}' | sed 's/%//')
    [[ $root_usage -gt 90 ]] && log "${RED}⚠ Root ${root_usage}% full${NC}" || log "${GREEN}✓ Disk OK (${root_usage}% used)${NC}"
    free -h | tee -a "$LOG_FILE"
    systemctl --failed --no-pager | tee -a "$LOG_FILE"
    journalctl -p 3 -n 5 --no-pager | tee -a "$LOG_FILE"
}

clean_old_logs() {
    log "${YELLOW}[7] Cleaning old maintenance logs...${NC}"
    log_count=$(ls -1 "$LOG_DIR"/*.log 2>/dev/null | wc -l)
    if [[ $log_count -gt $KEEP_LOGS ]]; then
        ls -1t "$LOG_DIR"/*.log | tail -n +$((KEEP_LOGS + 1)) | xargs rm -f
        log "${GREEN}✓ Old logs cleaned (kept $KEEP_LOGS)${NC}"
    else
        log "${GREEN}✓ No old logs to clean${NC}"
    fi
}

summary() {
    log "${CYAN}=== MAINTENANCE SUMMARY ===${NC}"
    log "Updates checked"
    log "Package cache cleaned"
    log "Orphans removed"
    log "Logs cleaned"
    log "User cache cleaned"
    log "System health checked"
    log "Old logs rotated"
    log "Log file: $LOG_FILE"
}

# --- Full Run ---
full_maintenance() {
    check_updates
    clean_pkg_cache
    remove_orphans
    clean_logs
    clean_user_cache
    system_health
    clean_old_logs
    summary
    log "${GREEN}✓ Weekly maintenance complete${NC}"
}

# --- Menu ---
menu() {
    echo "Weekly Maintenance Menu"
    echo "1) Full maintenance"
    echo "2) Check updates"
    echo "3) Clean package cache"
    echo "4) Remove orphans"
    echo "5) Clean logs"
    echo "6) Clean user cache"
    echo "7) System health check"
    echo "8) Clean old logs"
    echo "9) Summary"
    echo "0) Exit"
    read -rp "Choose option: " opt
    case $opt in
        1) full_maintenance ;;
        2) check_updates ;;
        3) clean_pkg_cache ;;
        4) remove_orphans ;;
        5) clean_logs ;;
        6) clean_user_cache ;;
        7) system_health ;;
        8) clean_old_logs ;;
        9) summary ;;
        0) exit 0 ;;
        *) log "${RED}Invalid option${NC}" ;;
    esac
}

# --- Flags ---
case "$1" in
    --full) full_maintenance ;;
    --updates) check_updates ;;
    --cache) clean_pkg_cache ;;
    --orphans) remove_orphans ;;
    --logs) clean_logs ;;
    --user-cache) clean_user_cache ;;
    --health) system_health ;;
    --rotate-logs) clean_old_logs ;;
    --summary) summary ;;
    *) menu ;;
esac
