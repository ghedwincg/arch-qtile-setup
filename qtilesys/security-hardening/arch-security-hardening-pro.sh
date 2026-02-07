#!/usr/bin/env bash

###############################################################################
# ARCH LINUX PRO SECURITY HARDENING SUITE
# Professional-grade security configuration with safety & rollback
# Version: 2.0
###############################################################################

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# ============================================================================
# CONFIGURATION
# ============================================================================

readonly SCRIPT_VERSION="2.0"
readonly SCRIPT_NAME="Arch Security Hardening Pro"

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Paths
readonly LOG_DIR="/var/log/security-hardening"
readonly BACKUP_DIR="/var/backups/security-hardening"
readonly CONFIG_DIR="/etc/security-hardening"
readonly TIMESTAMP=$(date +%Y%m%d_%H%M%S)
readonly LOG_FILE="$LOG_DIR/hardening_$TIMESTAMP.log"
readonly STATE_FILE="$CONFIG_DIR/hardening_state.conf"

# Script state
DRY_RUN=false
INTERACTIVE=true
FORCE=false
SKIP_BACKUP=false
PROFILE="standard"  # minimal, standard, paranoid

# Statistics
STEPS_TOTAL=15
STEPS_COMPLETED=0
ERRORS_FOUND=0
WARNINGS_FOUND=0
CHANGES_MADE=0

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║        ARCH LINUX PRO SECURITY HARDENING SUITE v2.0                  ║
║                                                                       ║
║   Professional security configuration with safety & rollback          ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

# Enhanced logging with levels and timestamps
log() {
    local level="${2:-INFO}"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    case "$level" in
        ERROR)
            echo -e "${RED}[✗ ERROR]${NC} $1" | tee -a "$LOG_FILE"
            ((ERRORS_FOUND++))
            ;;
        WARN)
            echo -e "${YELLOW}[⚠ WARN]${NC} $1" | tee -a "$LOG_FILE"
            ((WARNINGS_FOUND++))
            ;;
        SUCCESS)
            echo -e "${GREEN}[✓ OK]${NC} $1" | tee -a "$LOG_FILE"
            ;;
        INFO)
            echo -e "${CYAN}[ℹ INFO]${NC} $1" | tee -a "$LOG_FILE"
            ;;
        CHANGE)
            echo -e "${MAGENTA}[⚙ CHANGE]${NC} $1" | tee -a "$LOG_FILE"
            ((CHANGES_MADE++))
            ;;
        SKIP)
            echo -e "${BLUE}[⊘ SKIP]${NC} $1" | tee -a "$LOG_FILE"
            ;;
    esac
    
    echo "[$timestamp][$level] $1" >> "$LOG_FILE"
}

section_header() {
    ((STEPS_COMPLETED++))
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  [$STEPS_COMPLETED/$STEPS_TOTAL] $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "$1" "INFO"
}

confirm_action() {
    if [[ "$INTERACTIVE" == false ]] || [[ "$FORCE" == true ]]; then
        return 0
    fi
    
    local prompt="$1"
    local default="${2:-n}"
    
    while true; do
        read -rp "$(echo -e "${YELLOW}$prompt [y/n] (default: $default): ${NC}")" response
        response=${response:-$default}
        
        case "$response" in
            [Yy]* ) return 0;;
            [Nn]* ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

check_command() {
    if ! command -v "$1" &> /dev/null; then
        log "Required command not found: $1" "ERROR"
        return 1
    fi
    return 0
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        log "Don't run this script as root! Use sudo when prompted." "ERROR"
        exit 1
    fi
}

check_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log "This script requires sudo privileges" "INFO"
        sudo -v || exit 1
    fi
    # Keep sudo alive
    while true; do sudo -n true; sleep 50; kill -0 "$$" || exit; done 2>/dev/null &
}

# ============================================================================
# BACKUP & RESTORE FUNCTIONS
# ============================================================================

create_backup() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        log "Skipping backup (--no-backup flag set)" "WARN"
        return 0
    fi
    
    section_header "Creating System Backup"
    
    local backup_path="$BACKUP_DIR/backup_$TIMESTAMP"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would create backup at: $backup_path" "INFO"
        return 0
    fi
    
    sudo mkdir -p "$backup_path"
    
    # Backup critical files
    local files_to_backup=(
        "/etc/ssh/sshd_config"
        "/etc/sysctl.conf"
        "/etc/sysctl.d/"
        "/etc/ufw/"
        "/etc/fail2ban/"
        "/etc/security/"
        "/etc/pam.d/"
        "/etc/audit/"
        "/etc/hosts.allow"
        "/etc/hosts.deny"
    )
    
    log "Backing up critical system files..." "INFO"
    
    for item in "${files_to_backup[@]}"; do
        if [[ -e "$item" ]]; then
            local dest="$backup_path$(dirname "$item")"
            sudo mkdir -p "$dest"
            sudo cp -a "$item" "$dest/" 2>/dev/null || true
        fi
    done
    
    # Create manifest
    cat > "$backup_path/MANIFEST.txt" << EOF
Security Hardening Backup
Created: $(date)
Script Version: $SCRIPT_VERSION
Hostname: $(hostname)
Kernel: $(uname -r)
Profile: $PROFILE

Backed up files:
$(find "$backup_path" -type f -printf "%P\n" | sort)
EOF
    
    # Save current state
    {
        echo "# System state before hardening"
        echo "FIREWALL_STATUS=$(sudo ufw status 2>/dev/null | grep -i status || echo 'not active')"
        echo "SSH_STATUS=$(systemctl is-active sshd 2>/dev/null || echo 'inactive')"
        echo "APPARMOR_STATUS=$(systemctl is-active apparmor 2>/dev/null || echo 'inactive')"
        echo "FAIL2BAN_STATUS=$(systemctl is-active fail2ban 2>/dev/null || echo 'inactive')"
    } | sudo tee "$backup_path/system_state.conf" > /dev/null
    
    sudo chmod -R 700 "$backup_path"
    
    log "Backup created: $backup_path" "SUCCESS"
    
    # Cleanup old backups (keep last 5)
    local backup_count
    backup_count=$(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" 2>/dev/null | wc -l)
    
    if [[ $backup_count -gt 5 ]]; then
        log "Cleaning old backups (keeping last 5)..." "INFO"
        find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" | sort | head -n -5 | xargs sudo rm -rf
    fi
}

restore_from_backup() {
    section_header "Restore from Backup"
    
    if [[ ! -d "$BACKUP_DIR" ]]; then
        log "No backups found in $BACKUP_DIR" "ERROR"
        return 1
    fi
    
    local backups
    mapfile -t backups < <(find "$BACKUP_DIR" -maxdepth 1 -type d -name "backup_*" | sort -r)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        log "No backups available" "ERROR"
        return 1
    fi
    
    echo -e "${CYAN}Available backups:${NC}"
    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        local timestamp
        timestamp=$(basename "$backup" | sed 's/backup_//')
        echo "  $((i+1)). $timestamp"
        
        if [[ -f "$backup/MANIFEST.txt" ]]; then
            echo "     $(grep "Created:" "$backup/MANIFEST.txt" | head -1)"
        fi
    done
    
    read -rp "Enter backup number to restore (or 0 to cancel): " choice
    
    if [[ "$choice" -eq 0 ]]; then
        log "Restoration cancelled" "INFO"
        return 0
    fi
    
    if [[ "$choice" -gt 0 ]] && [[ "$choice" -le ${#backups[@]} ]]; then
        local selected="${backups[$((choice-1))]}"
        
        if confirm_action "Restore backup from $selected? This will overwrite current security configurations"; then
            # Restore files
            log "Restoring files from backup..." "INFO"
            
            find "$selected" -type f ! -name "MANIFEST.txt" ! -name "system_state.conf" | while read -r file; do
                local relative_path="${file#$selected}"
                sudo cp -a "$file" "$relative_path" 2>/dev/null || true
            done
            
            log "Backup restored successfully" "SUCCESS"
            log "Restart affected services manually" "WARN"
        fi
    else
        log "Invalid selection" "ERROR"
    fi
}

# ============================================================================
# SYSTEM UPDATE
# ============================================================================

update_system() {
    section_header "System Update"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would update system packages" "INFO"
        return 0
    fi
    
    log "Updating package databases..." "INFO"
    sudo pacman -Sy --noconfirm
    
    local updates
    updates=$(pacman -Qu | wc -l)
    
    if [[ $updates -gt 0 ]]; then
        log "Found $updates packages to update" "INFO"
        
        if confirm_action "Update all packages now? (Recommended)"; then
            sudo pacman -Su --noconfirm
            log "System updated successfully" "SUCCESS"
        else
            log "Skipped system update" "WARN"
        fi
    else
        log "System is already up to date" "SUCCESS"
    fi
}

# ============================================================================
# SECURITY TOOLS INSTALLATION
# ============================================================================

install_security_tools() {
    section_header "Security Tools Installation"
    
    # Tool categories based on profiles
    local core_tools=(
        "ufw"           # Firewall
        "fail2ban"      # Intrusion prevention
        "lynis"         # Security audit
    )
    
    local standard_tools=(
        "rkhunter"      # Rootkit detection
        "firejail"      # Application sandboxing
        "apparmor"      # MAC system
        "audit"         # Audit framework
        "arch-audit"    # Arch-specific CVE scanner
    )
    
    local paranoid_tools=(
        "clamav"        # Antivirus
        "aide"          # File integrity checker
        "tiger"         # Security scanner
    )
    
    local tools_to_install=("${core_tools[@]}")
    
    case "$PROFILE" in
        standard)
            tools_to_install+=("${standard_tools[@]}")
            ;;
        paranoid)
            tools_to_install+=("${standard_tools[@]}" "${paranoid_tools[@]}")
            ;;
    esac
    
    log "Installing security tools for profile: $PROFILE" "INFO"
    
    local to_install=()
    for tool in "${tools_to_install[@]}"; do
        if ! pacman -Qi "$tool" &> /dev/null; then
            to_install+=("$tool")
        else
            log "$tool already installed" "SUCCESS"
        fi
    done
    
    if [[ ${#to_install[@]} -gt 0 ]]; then
        log "Installing: ${to_install[*]}" "INFO"
        
        if [[ "$DRY_RUN" == false ]]; then
            sudo pacman -S --needed --noconfirm "${to_install[@]}"
            log "Security tools installed" "CHANGE"
        else
            log "[DRY RUN] Would install: ${to_install[*]}" "INFO"
        fi
    else
        log "All required tools already installed" "SUCCESS"
    fi
}

# ============================================================================
# FIREWALL CONFIGURATION
# ============================================================================

configure_firewall() {
    section_header "Firewall Configuration (UFW)"
    
    if ! command -v ufw &> /dev/null; then
        log "UFW not installed, skipping..." "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure UFW firewall" "INFO"
        return 0
    fi
    
    log "Configuring UFW firewall..." "INFO"
    
    # Reset to default state
    sudo ufw --force reset > /dev/null
    
    # Set defaults
    sudo ufw default deny incoming
    sudo ufw default allow outgoing
    sudo ufw default deny routed
    
    # Logging
    case "$PROFILE" in
        minimal)
            sudo ufw logging low
            ;;
        standard)
            sudo ufw logging medium
            ;;
        paranoid)
            sudo ufw logging high
            ;;
    esac
    
    # SSH with rate limiting (if SSH is installed and running)
    if systemctl is-active --quiet sshd || systemctl is-active --quiet ssh; then
        if confirm_action "Enable SSH access with rate limiting?"; then
            sudo ufw limit ssh comment 'SSH with rate limiting'
            log "SSH access enabled with rate limiting" "CHANGE"
        fi
    fi
    
    # Common services (ask user)
    if confirm_action "Enable HTTP (port 80)?"; then
        sudo ufw allow 80/tcp comment 'HTTP'
        log "HTTP enabled" "CHANGE"
    fi
    
    if confirm_action "Enable HTTPS (port 443)?"; then
        sudo ufw allow 443/tcp comment 'HTTPS'
        log "HTTPS enabled" "CHANGE"
    fi
    
    # Enable firewall
    sudo ufw --force enable
    sudo systemctl enable --now ufw
    
    log "Firewall configured and enabled" "SUCCESS"
    
    echo -e "\n${CYAN}Current firewall status:${NC}"
    sudo ufw status verbose | tee -a "$LOG_FILE"
}

# ============================================================================
# FAIL2BAN CONFIGURATION
# ============================================================================

configure_fail2ban() {
    section_header "Intrusion Prevention (Fail2Ban)"
    
    if ! command -v fail2ban-server &> /dev/null; then
        log "Fail2Ban not installed, skipping..." "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure Fail2Ban" "INFO"
        return 0
    fi
    
    log "Configuring Fail2Ban..." "INFO"
    
    # Create jail.local with adaptive settings
    local bantime findtime maxretry
    
    case "$PROFILE" in
        minimal)
            bantime=3600
            findtime=600
            maxretry=5
            ;;
        standard)
            bantime=86400
            findtime=600
            maxretry=3
            ;;
        paranoid)
            bantime=604800  # 1 week
            findtime=300
            maxretry=2
            ;;
    esac
    
    sudo tee /etc/fail2ban/jail.local > /dev/null << EOJAIL
[DEFAULT]
bantime = $bantime
findtime = $findtime
maxretry = $maxretry
destemail = root@localhost
sendername = Fail2Ban-$(hostname)
action = %(action_mwl)s
backend = systemd

[sshd]
enabled = true
port = ssh
logpath = %(sshd_log)s
maxretry = $maxretry
bantime = $bantime

[sshd-ddos]
enabled = true
port = ssh
logpath = %(sshd_log)s
maxretry = 10
findtime = 300
bantime = 3600
EOJAIL
    
    # Enable and start
    sudo systemctl enable --now fail2ban
    sudo systemctl restart fail2ban
    
    log "Fail2Ban configured (bantime: ${bantime}s, maxretry: $maxretry)" "CHANGE"
    
    # Show status
    echo -e "\n${CYAN}Fail2Ban status:${NC}"
    sudo fail2ban-client status | tee -a "$LOG_FILE"
}

# ============================================================================
# SSH HARDENING
# ============================================================================

harden_ssh() {
    section_header "SSH Hardening"
    
    local ssh_config="/etc/ssh/sshd_config"
    
    if [[ ! -f "$ssh_config" ]]; then
        log "SSH not installed, skipping..." "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would harden SSH configuration" "INFO"
        return 0
    fi
    
    if ! confirm_action "Harden SSH configuration? (Disables password auth, root login)"; then
        log "SSH hardening skipped by user" "SKIP"
        return 0
    fi
    
    log "Hardening SSH configuration..." "INFO"
    
    # Backup original
    sudo cp "$ssh_config" "${ssh_config}.bak-$TIMESTAMP"
    
    # Apply hardening based on profile
    local max_auth_tries port_config
    
    case "$PROFILE" in
        minimal)
            max_auth_tries=5
            ;;
        standard)
            max_auth_tries=3
            ;;
        paranoid)
            max_auth_tries=2
            # Ask about custom SSH port
            if confirm_action "Change SSH port from 22 to custom port? (Security through obscurity)"; then
                read -rp "Enter custom SSH port (1024-65535): " custom_port
                if [[ "$custom_port" =~ ^[0-9]+$ ]] && [[ "$custom_port" -ge 1024 ]] && [[ "$custom_port" -le 65535 ]]; then
                    port_config="Port $custom_port"
                    log "SSH port changed to $custom_port" "CHANGE"
                fi
            fi
            ;;
    esac
    
    # Create hardened config
    sudo tee "$ssh_config" > /dev/null << EOSSH
# Hardened SSH Configuration
# Generated by Security Hardening Script v$SCRIPT_VERSION
# Profile: $PROFILE
# Date: $(date)

# Network
${port_config:-Port 22}
AddressFamily inet
ListenAddress 0.0.0.0

# Protocol
Protocol 2

# Host Keys
HostKey /etc/ssh/ssh_host_rsa_key
HostKey /etc/ssh/ssh_host_ed25519_key

# Ciphers and keying
Ciphers chacha20-poly1305@openssh.com,aes256-gcm@openssh.com,aes128-gcm@openssh.com,aes256-ctr,aes192-ctr,aes128-ctr
MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256
KexAlgorithms curve25519-sha256,curve25519-sha256@libssh.org,diffie-hellman-group16-sha512,diffie-hellman-group18-sha512

# Logging
SyslogFacility AUTH
LogLevel VERBOSE

# Authentication
LoginGraceTime 30
PermitRootLogin no
StrictModes yes
MaxAuthTries $max_auth_tries
MaxSessions 5

PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys

PasswordAuthentication no
PermitEmptyPasswords no
ChallengeResponseAuthentication no

# Kerberos & GSSAPI
KerberosAuthentication no
GSSAPIAuthentication no

# Forwarding
X11Forwarding no
X11DisplayOffset 10
PrintMotd no
PrintLastLog yes
TCPKeepAlive yes
PermitUserEnvironment no
AllowAgentForwarding no
AllowTcpForwarding no
PermitTunnel no

# Other
Banner /etc/ssh/banner
ClientAliveInterval 300
ClientAliveCountMax 2
UsePAM yes
Subsystem sftp /usr/lib/ssh/sftp-server

# Limit users (uncomment and customize as needed)
# AllowUsers user1 user2
# DenyUsers root
EOSSH
    
    # Create SSH banner
    sudo tee /etc/ssh/banner > /dev/null << EOBANNER
***************************************************************************
                        AUTHORIZED ACCESS ONLY
***************************************************************************

Unauthorized access to this system is forbidden and will be prosecuted.
All activities on this system are monitored and recorded.

***************************************************************************
EOBANNER
    
    # Test configuration
    if sudo sshd -t 2>&1 | tee -a "$LOG_FILE"; then
        log "SSH configuration test passed" "SUCCESS"
        
        if systemctl is-active --quiet sshd || systemctl is-active --quiet ssh; then
            log "WARNING: SSH service will be restarted. Ensure you have another way to access the system!" "WARN"
            
            if confirm_action "Restart SSH service now?"; then
                sudo systemctl restart sshd 2>/dev/null || sudo systemctl restart ssh
                log "SSH service restarted" "CHANGE"
            else
                log "SSH service NOT restarted - changes will apply on next reboot" "WARN"
            fi
        fi
    else
        log "SSH configuration test failed! Reverting to backup" "ERROR"
        sudo mv "${ssh_config}.bak-$TIMESTAMP" "$ssh_config"
        return 1
    fi
}

# ============================================================================
# APPARMOR CONFIGURATION
# ============================================================================

configure_apparmor() {
    section_header "Mandatory Access Control (AppArmor)"
    
    if ! command -v aa-status &> /dev/null; then
        log "AppArmor not installed, skipping..." "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure AppArmor" "INFO"
        return 0
    fi
    
    log "Configuring AppArmor..." "INFO"
    
    # Enable AppArmor service
    sudo systemctl enable --now apparmor
    
    # Set profiles to enforce mode (be careful with this)
    if [[ "$PROFILE" == "paranoid" ]]; then
        if confirm_action "Set ALL AppArmor profiles to enforce mode? (May break applications)"; then
            sudo aa-enforce /etc/apparmor.d/* 2>/dev/null || true
            log "AppArmor profiles set to enforce mode" "CHANGE"
        fi
    else
        # More conservative approach
        log "Setting critical profiles to enforce mode..." "INFO"
        
        local critical_profiles=(
            "/etc/apparmor.d/usr.sbin.tcpdump"
            "/etc/apparmor.d/usr.bin.man"
        )
        
        for profile in "${critical_profiles[@]}"; do
            if [[ -f "$profile" ]]; then
                sudo aa-enforce "$profile" 2>/dev/null || true
            fi
        done
    fi
    
    log "AppArmor configured" "SUCCESS"
    
    echo -e "\n${CYAN}AppArmor status:${NC}"
    sudo aa-status 2>&1 | head -30 | tee -a "$LOG_FILE"
}

# ============================================================================
# AUDIT DAEMON
# ============================================================================

configure_audit() {
    section_header "System Auditing (auditd)"
    
    if ! command -v auditctl &> /dev/null; then
        log "Auditd not installed, skipping..." "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure audit daemon" "INFO"
        return 0
    fi
    
    log "Configuring audit daemon..." "INFO"
    
    # Create audit rules based on profile
    local rules_file="/etc/audit/rules.d/hardening.rules"
    
    sudo tee "$rules_file" > /dev/null << 'EORULES'
# System Audit Rules - Security Hardening
# Generated by Security Hardening Script

# Remove any existing rules
-D

# Buffer size
-b 8192

# Failure mode (0=silent 1=printk 2=panic)
-f 1

# Monitor critical file modifications
-w /etc/passwd -p wa -k passwd_changes
-w /etc/group -p wa -k group_changes
-w /etc/shadow -p wa -k shadow_changes
-w /etc/gshadow -p wa -k shadow_changes
-w /etc/sudoers -p wa -k sudoers_changes
-w /etc/sudoers.d/ -p wa -k sudoers_changes

# Monitor SSH configuration
-w /etc/ssh/sshd_config -p wa -k sshd_config_changes

# Monitor network configuration
-w /etc/hosts -p wa -k network_modifications
-w /etc/network/ -p wa -k network_modifications
-w /etc/NetworkManager/ -p wa -k network_modifications

# Monitor kernel module loading
-w /sbin/insmod -p x -k kernel_modules
-w /sbin/rmmod -p x -k kernel_modules
-w /sbin/modprobe -p x -k kernel_modules
-a always,exit -F arch=b64 -S init_module,delete_module -k kernel_modules

# Monitor time changes
-a always,exit -F arch=b64 -S adjtimex,settimeofday -k time_change
-a always,exit -F arch=b32 -S adjtimex,settimeofday,stime -k time_change
-w /etc/localtime -p wa -k time_change

# Monitor privileged commands
-a always,exit -F path=/usr/bin/sudo -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged_commands
-a always,exit -F path=/usr/bin/su -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged_commands

# Monitor successful/failed login attempts
-w /var/log/faillog -p wa -k login_attempts
-w /var/log/lastlog -p wa -k login_attempts
-w /var/run/utmp -p wa -k session
-w /var/log/wtmp -p wa -k session
-w /var/log/btmp -p wa -k session

# Make configuration immutable
-e 2
EORULES
    
    # Load rules
    sudo augenrules --load
    
    # Enable and start service
    sudo systemctl enable --now auditd
    
    log "Audit daemon configured" "SUCCESS"
    
    echo -e "\n${CYAN}Audit status:${NC}"
    sudo auditctl -l | head -20 | tee -a "$LOG_FILE"
}

# ============================================================================
# KERNEL HARDENING
# ============================================================================

harden_kernel() {
    section_header "Kernel Parameter Hardening (sysctl)"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure kernel parameters" "INFO"
        return 0
    fi
    
    log "Hardening kernel parameters..." "INFO"
    
    local sysctl_file="/etc/sysctl.d/99-security-hardening.conf"
    
    # Kernel hardening based on profile
    case "$PROFILE" in
        minimal)
            sudo tee "$sysctl_file" > /dev/null << 'EOSYSCTL'
# Kernel Security Hardening - Minimal Profile
# Generated by Security Hardening Script

# Network Security
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# Kernel Protection
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 1
EOSYSCTL
            ;;
        standard)
            sudo tee "$sysctl_file" > /dev/null << 'EOSYSCTL'
# Kernel Security Hardening - Standard Profile
# Generated by Security Hardening Script

# IP Forwarding (disable if not a router)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Network Security
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# TCP/IP Stack Hardening
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syn_retries = 3
net.ipv4.tcp_synack_retries = 2

# Kernel Protection
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.printk = 3 3 3 3
kernel.yama.ptrace_scope = 1

# Filesystem Protection
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
EOSYSCTL
            ;;
        paranoid)
            sudo tee "$sysctl_file" > /dev/null << 'EOSYSCTL'
# Kernel Security Hardening - Paranoid Profile
# Generated by Security Hardening Script
# WARNING: Some settings may impact functionality

# IP Forwarding (disable)
net.ipv4.ip_forward = 0
net.ipv6.conf.all.forwarding = 0

# Network Security (Maximum)
net.ipv4.conf.all.rp_filter = 1
net.ipv4.conf.default.rp_filter = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.conf.all.accept_redirects = 0
net.ipv6.conf.all.accept_redirects = 0
net.ipv4.conf.default.accept_redirects = 0
net.ipv6.conf.default.accept_redirects = 0
net.ipv4.conf.all.secure_redirects = 0
net.ipv4.conf.all.send_redirects = 0
net.ipv4.conf.default.send_redirects = 0
net.ipv4.conf.all.accept_source_route = 0
net.ipv6.conf.all.accept_source_route = 0
net.ipv4.conf.all.log_martians = 1

# ICMP (disable ping)
net.ipv4.icmp_echo_ignore_all = 1
net.ipv4.icmp_echo_ignore_broadcasts = 1
net.ipv4.icmp_ignore_bogus_error_responses = 1

# IPv6 (disable if not needed)
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1

# TCP/IP Stack Hardening
net.ipv4.tcp_timestamps = 0
net.ipv4.tcp_syn_retries = 2
net.ipv4.tcp_synack_retries = 1
net.ipv4.tcp_max_syn_backlog = 2048

# Kernel Protection (Maximum)
kernel.dmesg_restrict = 1
kernel.kptr_restrict = 2
kernel.printk = 3 3 3 3
kernel.yama.ptrace_scope = 2
kernel.kexec_load_disabled = 1

# Filesystem Protection
fs.suid_dumpable = 0
fs.protected_hardlinks = 1
fs.protected_symlinks = 1
fs.protected_fifos = 2
fs.protected_regular = 2

# Memory Protection
vm.mmap_min_addr = 65536
EOSYSCTL
            ;;
    esac
    
    # Apply settings
    sudo sysctl --system
    
    log "Kernel parameters hardened (profile: $PROFILE)" "CHANGE"
    
    echo -e "\n${CYAN}Applied sysctl settings:${NC}"
    sudo sysctl -a 2>/dev/null | grep -E "net.ipv4|kernel" | head -20 | tee -a "$LOG_FILE"
}

# ============================================================================
# FILE PERMISSIONS
# ============================================================================

secure_file_permissions() {
    section_header "File Permissions Hardening"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would secure file permissions" "INFO"
        return 0
    fi
    
    log "Securing critical file permissions..." "INFO"
    
    # Secure critical files
    sudo chmod 600 /boot/grub/grub.cfg 2>/dev/null || true
    sudo chmod 700 /root
    sudo chmod 644 /etc/passwd
    sudo chmod 644 /etc/group
    sudo chmod 600 /etc/shadow
    sudo chmod 600 /etc/gshadow
    sudo chmod 644 /etc/fstab
    
    log "Critical file permissions secured" "CHANGE"
    
    # Find world-writable files (potential security risk)
    log "Scanning for world-writable files..." "INFO"
    
    local writable_count
    writable_count=$(find / -xdev -type f -perm -0002 2>/dev/null | wc -l)
    
    if [[ $writable_count -gt 0 ]]; then
        log "Found $writable_count world-writable files" "WARN"
        log "Review list in: /tmp/world-writable-files.txt" "INFO"
        find / -xdev -type f -perm -0002 2>/dev/null > /tmp/world-writable-files.txt
    else
        log "No suspicious world-writable files found" "SUCCESS"
    fi
    
    # Find SUID binaries
    log "Scanning for SUID binaries..." "INFO"
    find / -xdev -type f -perm -4000 2>/dev/null > /tmp/suid-binaries.txt
    local suid_count
    suid_count=$(wc -l < /tmp/suid-binaries.txt)
    log "Found $suid_count SUID binaries (review /tmp/suid-binaries.txt)" "INFO"
}

# ============================================================================
# SERVICE MANAGEMENT
# ============================================================================

manage_services() {
    section_header "Unnecessary Services Management"
    
    # List of potentially unnecessary services
    local potentially_unnecessary=(
        "bluetooth.service"
        "cups.service"
        "avahi-daemon.service"
        "ModemManager.service"
    )
    
    log "Checking for unnecessary services..." "INFO"
    
    for service in "${potentially_unnecessary[@]}"; do
        if systemctl is-enabled "$service" 2>/dev/null | grep -q enabled; then
            log "Service $service is enabled" "INFO"
            
            if confirm_action "Disable $service?"; then
                if [[ "$DRY_RUN" == false ]]; then
                    sudo systemctl disable --now "$service"
                    log "$service disabled" "CHANGE"
                else
                    log "[DRY RUN] Would disable $service" "INFO"
                fi
            else
                log "Keeping $service enabled" "SKIP"
            fi
        fi
    done
}

# ============================================================================
# AUTOMATIC UPDATE NOTIFICATIONS
# ============================================================================

setup_update_notifications() {
    section_header "Automatic Update Notifications"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would setup update notifications" "INFO"
        return 0
    fi
    
    log "Setting up automatic security update checks..." "INFO"
    
    # Create check script
    sudo tee /usr/local/bin/check-security-updates > /dev/null << 'EOSCRIPT'
#!/usr/bin/env bash

# Update package database
pacman -Sy > /dev/null 2>&1

# Count updates
updates=$(pacman -Qu | wc -l)
security_updates=$(arch-audit -u 2>/dev/null | wc -l || echo 0)

if [[ $updates -gt 0 ]]; then
    # Try desktop notification
    if command -v notify-send &> /dev/null; then
        DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus \
            notify-send -u critical -i security-high "Security Updates Available" \
            "$updates total packages\n$security_updates security-related" 2>/dev/null || true
    fi
    
    # Log to journal
    echo "Updates available: $updates total, $security_updates security-related" | \
        systemd-cat -t security-updates -p warning
fi
EOSCRIPT
    
    sudo chmod +x /usr/local/bin/check-security-updates
    
    # Create systemd service
    sudo tee /etc/systemd/system/check-security-updates.service > /dev/null << 'EOSERVICE'
[Unit]
Description=Check for security updates
After=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/check-security-updates
User=root
EOSERVICE
    
    # Create systemd timer
    sudo tee /etc/systemd/system/check-security-updates.timer > /dev/null << 'EOTIMER'
[Unit]
Description=Daily security updates check

[Timer]
OnCalendar=daily
Persistent=true
RandomizedDelaySec=1h

[Install]
WantedBy=timers.target
EOTIMER
    
    # Enable timer
    sudo systemctl daemon-reload
    sudo systemctl enable --now check-security-updates.timer
    
    log "Automatic update notifications configured" "CHANGE"
}

# ============================================================================
# CLAMAV ANTIVIRUS
# ============================================================================

setup_clamav() {
    section_header "Antivirus Configuration (ClamAV)"
    
    if [[ "$PROFILE" != "paranoid" ]]; then
        log "ClamAV only installed in paranoid profile" "SKIP"
        return 0
    fi
    
    if ! command -v freshclam &> /dev/null; then
        log "ClamAV not installed, skipping..." "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure ClamAV" "INFO"
        return 0
    fi
    
    log "Configuring ClamAV antivirus..." "INFO"
    
    # Update virus definitions
    log "Updating virus definitions (this may take a while)..." "INFO"
    sudo freshclam || log "Failed to update virus definitions" "WARN"
    
    # Enable automatic updates
    sudo systemctl enable --now clamav-freshclam
    
    log "ClamAV configured" "SUCCESS"
    log "Run manual scan with: sudo clamscan -r /home" "INFO"
}

# ============================================================================
# USB RESTRICTIONS
# ============================================================================

configure_usb_restrictions() {
    section_header "USB Device Restrictions"
    
    if [[ "$PROFILE" != "paranoid" ]]; then
        log "USB restrictions only available in paranoid profile" "SKIP"
        return 0
    fi
    
    if ! confirm_action "Configure USB restrictions? (May prevent some USB devices from working)"; then
        log "USB restrictions skipped" "SKIP"
        return 0
    fi
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would configure USB restrictions" "INFO"
        return 0
    fi
    
    log "Configuring USB restrictions..." "INFO"
    
    # Create udev rule
    sudo tee /etc/udev/rules.d/99-usb-restrict.rules > /dev/null << 'EOUDEV'
# USB Security Restrictions
# Only allow specific USB devices (whitelist approach)

# Log all USB connections
ACTION=="add", SUBSYSTEM=="usb", RUN+="/usr/bin/logger -t usb-device 'USB device connected: %k'"

# Uncomment to block all USB storage (except whitelisted)
# ACTION=="add", SUBSYSTEMS=="usb", SUBSYSTEM=="block", ENV{DEVTYPE}=="disk", ATTR{authorized}="0"

# Whitelist specific devices (example - add your devices)
# ACTION=="add", SUBSYSTEMS=="usb", ATTRS{idVendor}=="0123", ATTRS{idProduct}=="4567", ATTR{authorized}="1"
EOUDEV
    
    sudo udevadm control --reload-rules
    
    log "USB restrictions configured (currently in logging-only mode)" "CHANGE"
    log "Edit /etc/udev/rules.d/99-usb-restrict.rules to enable blocking" "INFO"
}

# ============================================================================
# SECURITY REPORT GENERATION
# ============================================================================

generate_security_report() {
    section_header "Security Report Generation"
    
    local report_file="$HOME/security_report_$TIMESTAMP.txt"
    
    log "Generating comprehensive security report..." "INFO"
    
    {
        echo "==============================================================================="
        echo "                    SECURITY HARDENING REPORT"
        echo "==============================================================================="
        echo "Generated: $(date)"
        echo "Hostname: $(hostname)"
        echo "Kernel: $(uname -r)"
        echo "Profile: $PROFILE"
        echo "Script Version: $SCRIPT_VERSION"
        echo "==============================================================================="
        echo ""
        
        echo "=== FIREWALL STATUS ==="
        sudo ufw status verbose 2>/dev/null || echo "UFW not configured"
        echo ""
        
        echo "=== FAIL2BAN STATUS ==="
        sudo fail2ban-client status 2>/dev/null || echo "Fail2Ban not configured"
        echo ""
        
        echo "=== APPARMOR STATUS ==="
        sudo aa-status 2>/dev/null || echo "AppArmor not configured"
        echo ""
        
        echo "=== AUDIT STATUS ==="
        sudo auditctl -l 2>/dev/null | head -20 || echo "Auditd not configured"
        echo ""
        
        echo "=== LISTENING PORTS ==="
        sudo ss -tulpn
        echo ""
        
        echo "=== KERNEL PARAMETERS (Security-Related) ==="
        sudo sysctl -a 2>/dev/null | grep -E "net.ipv4|kernel|fs" | grep -v "ipv4.conf.lo"
        echo ""
        
        echo "=== SUID BINARIES ==="
        find / -xdev -perm -4000 -type f 2>/dev/null | sort
        echo ""
        
        echo "=== WORLD WRITABLE DIRECTORIES ==="
        find / -xdev -type d -perm -0002 2>/dev/null | head -30
        echo ""
        
        echo "=== ACTIVE SERVICES ==="
        systemctl list-units --type=service --state=running --no-pager
        echo ""
        
        echo "=== SSH CONFIGURATION ==="
        if [[ -f /etc/ssh/sshd_config ]]; then
            grep -v "^#" /etc/ssh/sshd_config | grep -v "^$"
        else
            echo "SSH not installed"
        fi
        echo ""
        
        echo "=== RECENT FAILED LOGIN ATTEMPTS ==="
        sudo journalctl -u sshd --since "24 hours ago" | grep -i failed | tail -20 2>/dev/null || echo "No recent failures"
        echo ""
        
        echo "=== SECURITY UPDATES AVAILABLE ==="
        pacman -Qu 2>/dev/null | wc -l
        if command -v arch-audit &> /dev/null; then
            arch-audit -u 2>/dev/null || echo "No critical CVEs"
        fi
        echo ""
        
        echo "==============================================================================="
        echo "                           END OF REPORT"
        echo "==============================================================================="
        
    } > "$report_file"
    
    log "Security report generated: $report_file" "SUCCESS"
    
    # Also create HTML version if possible
    if command -v pandoc &> /dev/null; then
        pandoc "$report_file" -f markdown -t html -o "${report_file%.txt}.html" 2>/dev/null || true
    fi
}

# ============================================================================
# LYNIS SECURITY AUDIT
# ============================================================================

run_lynis_audit() {
    section_header "Comprehensive Security Audit (Lynis)"
    
    if ! command -v lynis &> /dev/null; then
        log "Lynis not installed, skipping audit" "SKIP"
        return 0
    fi
    
    if ! confirm_action "Run Lynis security audit? (May take several minutes)"; then
        log "Lynis audit skipped" "SKIP"
        return 0
    fi
    
    log "Running Lynis security audit..." "INFO"
    
    sudo lynis audit system --quick --quiet | tee -a "$LOG_FILE"
    
    log "Lynis audit complete - check /var/log/lynis.log for details" "SUCCESS"
}

# ============================================================================
# INTERACTIVE MENU
# ============================================================================

interactive_menu() {
    while true; do
        echo -e "\n${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║         SECURITY HARDENING INTERACTIVE MENU               ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
        
        echo "  1) Run full hardening (recommended)"
        echo "  2) Create backup only"
        echo "  3) Restore from backup"
        echo "  4) Configure firewall only"
        echo "  5) Harden SSH only"
        echo "  6) Configure kernel parameters only"
        echo "  7) Setup update notifications only"
        echo "  8) Generate security report"
        echo "  9) Run Lynis audit"
        echo " 10) Check system status"
        echo "  0) Exit"
        
        echo ""
        read -rp "Select option: " choice
        
        case $choice in
            1) run_full_hardening ;;
            2) create_backup ;;
            3) restore_from_backup ;;
            4) configure_firewall ;;
            5) harden_ssh ;;
            6) harden_kernel ;;
            7) setup_update_notifications ;;
            8) generate_security_report ;;
            9) run_lynis_audit ;;
            10) check_system_status ;;
            0) log "Exiting..." "INFO"; exit 0 ;;
            *) log "Invalid option" "ERROR" ;;
        esac
        
        read -rp "Press Enter to continue..."
    done
}

check_system_status() {
    section_header "System Security Status"
    
    echo -e "${CYAN}Firewall:${NC}"
    sudo ufw status 2>/dev/null || echo "Not configured"
    
    echo -e "\n${CYAN}Fail2Ban:${NC}"
    sudo fail2ban-client status 2>/dev/null || echo "Not running"
    
    echo -e "\n${CYAN}AppArmor:${NC}"
    sudo aa-status 2>/dev/null | head -10 || echo "Not running"
    
    echo -e "\n${CYAN}SSH:${NC}"
    systemctl status sshd --no-pager 2>/dev/null || echo "Not running"
    
    echo -e "\n${CYAN}Audit:${NC}"
    systemctl status auditd --no-pager 2>/dev/null || echo "Not running"
    
    echo -e "\n${CYAN}Security Updates:${NC}"
    if command -v arch-audit &> /dev/null; then
        arch-audit -u 2>/dev/null || echo "No critical CVEs"
    else
        echo "arch-audit not installed"
    fi
}

# ============================================================================
# FULL HARDENING PROCESS
# ============================================================================

run_full_hardening() {
    log "Starting full security hardening (profile: $PROFILE)" "INFO"
    
    create_backup
    update_system
    install_security_tools
    configure_firewall
    configure_fail2ban
    harden_ssh
    configure_apparmor
    configure_audit
    harden_kernel
    secure_file_permissions
    manage_services
    setup_update_notifications
    setup_clamav
    configure_usb_restrictions
    generate_security_report
    
    show_summary
}

# ============================================================================
# SUMMARY
# ============================================================================

show_summary() {
    section_header "Hardening Summary"
    
    echo -e "${BOLD}Security Hardening Results:${NC}"
    echo -e "  ${GREEN}Changes made: $CHANGES_MADE${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS_FOUND${NC}"
    echo -e "  ${RED}Errors: $ERRORS_FOUND${NC}"
    echo ""
    
    if [[ $ERRORS_FOUND -gt 0 ]]; then
        log "Hardening completed with errors - review log" "WARN"
    else
        log "Security hardening completed successfully!" "SUCCESS"
    fi
    
    echo ""
    echo -e "${CYAN}${BOLD}CRITICAL NEXT STEPS:${NC}"
    echo -e "${YELLOW}1.${NC} Review the security report in your home directory"
    echo -e "${YELLOW}2.${NC} REBOOT your system to apply all changes"
    echo -e "${YELLOW}3.${NC} Test SSH access BEFORE logging out (if remote)"
    echo -e "${YELLOW}4.${NC} Run: ${CYAN}sudo lynis audit system${NC} for detailed analysis"
    echo -e "${YELLOW}5.${NC} Keep your system updated regularly"
    echo -e "${YELLOW}6.${NC} Review logs: ${CYAN}$LOG_FILE${NC}"
    echo ""
    
    echo -e "${CYAN}Useful commands:${NC}"
    echo -e "  • Firewall status: ${CYAN}sudo ufw status${NC}"
    echo -e "  • Fail2Ban status: ${CYAN}sudo fail2ban-client status${NC}"
    echo -e "  • Check CVEs: ${CYAN}arch-audit -u${NC}"
    echo -e "  • View audit logs: ${CYAN}sudo ausearch -ts recent${NC}"
    echo ""
    
    if [[ "$DRY_RUN" == true ]]; then
        echo -e "${YELLOW}${BOLD}NOTE: This was a DRY RUN - no changes were made${NC}"
    fi
}

# ============================================================================
# USAGE
# ============================================================================

show_usage() {
    cat << EOF
Arch Linux Pro Security Hardening Suite v${SCRIPT_VERSION}

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help           Show this help message
  -i, --interactive    Interactive menu mode (default)
  -a, --auto           Run full hardening automatically
  -d, --dry-run        Show what would be done without making changes
  -n, --no-backup      Skip backup creation (NOT recommended)
  -f, --force          Skip confirmation prompts
  -p, --profile PROF   Security profile: minimal, standard, paranoid (default: standard)
  -r, --restore        Restore from backup
  --version            Show version

Profiles:
  minimal   - Basic firewall, fail2ban, minimal kernel hardening
  standard  - Recommended for most users (default)
  paranoid  - Maximum security (may impact usability)

Examples:
  $(basename "$0")                           # Interactive mode
  $(basename "$0") --auto                    # Auto with standard profile
  $(basename "$0") --auto --profile paranoid # Auto with paranoid profile
  $(basename "$0") --dry-run --auto          # Preview changes
  $(basename "$0") --restore                 # Restore from backup

EOF
}

# ============================================================================
# INITIALIZATION
# ============================================================================

initialize() {
    # Create necessary directories
    sudo mkdir -p "$LOG_DIR" "$BACKUP_DIR" "$CONFIG_DIR"
    sudo chmod 700 "$BACKUP_DIR"
    sudo chmod 755 "$LOG_DIR" "$CONFIG_DIR"
    
    # Start logging
    touch "$LOG_FILE"
    log "Security Hardening Script v$SCRIPT_VERSION started" "INFO"
    log "Profile: $PROFILE" "INFO"
    log "Dry run: $DRY_RUN" "INFO"
}

# ============================================================================
# MAIN
# ============================================================================

main() {
    print_banner
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -i|--interactive)
                INTERACTIVE=true
                shift
                ;;
            -a|--auto)
                INTERACTIVE=false
                shift
                ;;
            -d|--dry-run)
                DRY_RUN=true
                log "DRY RUN MODE - No changes will be made" "INFO"
                shift
                ;;
            -n|--no-backup)
                SKIP_BACKUP=true
                shift
                ;;
            -f|--force)
                FORCE=true
                shift
                ;;
            -p|--profile)
                PROFILE="$2"
                if [[ ! "$PROFILE" =~ ^(minimal|standard|paranoid)$ ]]; then
                    log "Invalid profile: $PROFILE" "ERROR"
                    exit 1
                fi
                shift 2
                ;;
            -r|--restore)
                check_root
                check_sudo
                initialize
                restore_from_backup
                exit 0
                ;;
            --version)
                echo "Security Hardening Script v${SCRIPT_VERSION}"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Checks
    check_root
    check_sudo
    
    # Initialize
    initialize
    
    # Run
    if [[ "$INTERACTIVE" == true ]]; then
        interactive_menu
    else
        run_full_hardening
    fi
}

# Error handling
trap 'log "Script interrupted or failed at line $LINENO" "ERROR"; exit 1' ERR INT TERM

# Run
main "$@"
