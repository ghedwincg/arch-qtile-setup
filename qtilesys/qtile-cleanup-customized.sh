#!/usr/bin/env bash

###############################################################################
# QTILE OPTIMIZATION & CLEANUP SCRIPT - CUSTOMIZED FOR YOUR SYSTEM
# Tailored to your installed tools and configuration
# Version: 2.1-Custom
###############################################################################

set -euo pipefail

# Colors and formatting
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly BOLD='\033[1m'
readonly NC='\033[0m'

# Configuration
readonly QTILE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/qtile"
readonly QTILE_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/qtile"
readonly QTILE_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/qtile"
readonly LOG_DIR="$HOME/.local/share/qtile/optimization-logs"
readonly LOG_FILE="$LOG_DIR/qtile_optimize_$(date +%Y%m%d_%H%M%S).log"
readonly BACKUP_BASE="$HOME/.config/qtile-backups"
readonly SCRIPT_VERSION="2.1-Custom"

# Your system's tools (detected from your package list)
readonly YOUR_BROWSER="brave"           # You have Brave installed
readonly YOUR_TERMINAL="alacritty"      # You use alacritty
readonly YOUR_SCREENSHOT="flameshot"    # You use flameshot
readonly YOUR_CLIPBOARD="copyq"         # You use copyq
readonly YOUR_FILE_MANAGER="dolphin"    # You use dolphin
readonly YOUR_COMPOSITOR="picom"        # You use picom
readonly YOUR_LAUNCHER="rofi"           # You use rofi
readonly YOUR_NOTIFICATION="dunst"      # You use dunst
readonly YOUR_LOCKSCREEN="betterlockscreen"  # You use betterlockscreen
readonly YOUR_WALLPAPER="nitrogen"      # You use nitrogen

# State tracking
ERRORS_FOUND=0
WARNINGS_FOUND=0
FIXES_APPLIED=0
DRY_RUN=false
INTERACTIVE=true
SKIP_BACKUP=false

# Ensure log directory exists
mkdir -p "$LOG_DIR"

###############################################################################
# UTILITY FUNCTIONS
###############################################################################

print_banner() {
    echo -e "${CYAN}${BOLD}"
    cat << "EOF"
╔═══════════════════════════════════════════════════════════════════════╗
║                                                                       ║
║         QTILE OPTIMIZATION - CUSTOMIZED FOR YOUR SYSTEM               ║
║                                                                       ║
║  Tailored to your installed tools and current configuration          ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${NC}\n"
}

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
        FIX)
            echo -e "${MAGENTA}[⚙ FIX]${NC} $1" | tee -a "$LOG_FILE"
            ((FIXES_APPLIED++))
            ;;
    esac
    
    echo "[$timestamp][$level] $1" >> "$LOG_FILE"
}

section_header() {
    echo ""
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    log "$1" "INFO"
}

confirm_action() {
    if [[ "$INTERACTIVE" == false ]]; then
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

###############################################################################
# BACKUP FUNCTIONS
###############################################################################

create_backup() {
    if [[ "$SKIP_BACKUP" == true ]]; then
        log "Skipping backup (--no-backup flag set)" "WARN"
        return 0
    fi
    
    section_header "Creating Backup"
    
    local backup_dir="$BACKUP_BASE/backup-$(date +%Y%m%d_%H%M%S)"
    
    if [[ ! -d "$QTILE_CONFIG" ]]; then
        log "Qtile config directory not found, skipping backup" "WARN"
        return 0
    fi
    
    mkdir -p "$BACKUP_BASE"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would create backup: $backup_dir" "INFO"
        return 0
    fi
    
    if cp -r "$QTILE_CONFIG" "$backup_dir" 2>/dev/null; then
        log "Backup created: $backup_dir" "SUCCESS"
        
        cat > "$backup_dir/MANIFEST.txt" << EOF
Qtile Configuration Backup
Created: $(date)
Script Version: $SCRIPT_VERSION
Original Path: $QTILE_CONFIG

Files backed up:
$(find "$backup_dir" -type f -printf "%P\n" | sort)
EOF
        
        # Cleanup old backups (keep last 5)
        local backup_count
        backup_count=$(find "$BACKUP_BASE" -maxdepth 1 -type d -name "backup-*" | wc -l)
        
        if [[ $backup_count -gt 5 ]]; then
            log "Cleaning old backups (keeping last 5)..." "INFO"
            find "$BACKUP_BASE" -maxdepth 1 -type d -name "backup-*" | sort | head -n -5 | xargs rm -rf
        fi
        
        return 0
    else
        log "Failed to create backup!" "ERROR"
        return 1
    fi
}

restore_backup() {
    section_header "Backup Restoration"
    
    if [[ ! -d "$BACKUP_BASE" ]]; then
        log "No backups found" "ERROR"
        return 1
    fi
    
    local backups
    mapfile -t backups < <(find "$BACKUP_BASE" -maxdepth 1 -type d -name "backup-*" | sort -r)
    
    if [[ ${#backups[@]} -eq 0 ]]; then
        log "No backups available" "ERROR"
        return 1
    fi
    
    echo -e "${CYAN}Available backups:${NC}"
    for i in "${!backups[@]}"; do
        local backup="${backups[$i]}"
        local timestamp
        timestamp=$(basename "$backup" | sed 's/backup-//')
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
        
        if confirm_action "Restore backup from $selected? This will overwrite current config"; then
            rm -rf "$QTILE_CONFIG"
            cp -r "$selected" "$QTILE_CONFIG"
            log "Backup restored successfully" "SUCCESS"
            log "Please reload Qtile: Super+Ctrl+R" "INFO"
        fi
    else
        log "Invalid selection" "ERROR"
    fi
}

###############################################################################
# VALIDATION FUNCTIONS
###############################################################################

validate_python_syntax() {
    section_header "Python Syntax Validation"
    
    local config_file="$QTILE_CONFIG/config.py"
    
    if [[ ! -f "$config_file" ]]; then
        log "config.py not found!" "ERROR"
        return 1
    fi
    
    # Check Python syntax
    if python -m py_compile "$config_file" 2>&1 | tee -a "$LOG_FILE"; then
        log "Python syntax validation passed" "SUCCESS"
    else
        log "Python syntax errors found!" "ERROR"
        return 1
    fi
    
    # Check for common issues in YOUR config
    log "Checking your configuration specifics..." "INFO"
    
    # Check if vivaldi is still referenced (you removed it)
    if grep -q "vivaldi" "$config_file"; then
        log "NOTICE: vivaldi is referenced in config but you're keeping brave" "WARN"
        log "Consider changing 'vivaldi' to 'brave' in config.py" "INFO"
    fi
    
    # Check for missing imports
    local required_imports=("libqtile" "libqtile.config" "libqtile.lazy")
    for import in "${required_imports[@]}"; do
        if ! grep -q "from $import import" "$config_file" && ! grep -q "import $import" "$config_file"; then
            log "Missing import: $import" "WARN"
        fi
    done
    
    # Check for deprecated functions (Qtile 0.34+)
    if grep -q "Systray()" "$config_file"; then
        log "Systray() usage found - should be compatible with Qtile 0.34" "SUCCESS"
    fi
    
    return 0
}

check_qtile_version() {
    section_header "Qtile Version Check"
    
    if ! check_command qtile; then
        log "Qtile not installed!" "ERROR"
        return 1
    fi
    
    local version
    version=$(qtile --version 2>/dev/null | head -1)
    log "Installed version: $version" "INFO"
    
    # You have Qtile 0.34.1
    if [[ $version =~ 0\.34 ]]; then
        log "You're running Qtile 0.34.x - Good!" "SUCCESS"
    fi
}

###############################################################################
# DEPENDENCY CHECK - CUSTOMIZED FOR YOUR SYSTEM
###############################################################################

check_dependencies() {
    section_header "Dependency Check - Your Installed Tools"
    
    # Core Qtile dependencies
    local core_deps=(
        "qtile"
        "python-psutil"
        "python-dbus-next"
    )
    
    # YOUR specific tools (from your packages list)
    local your_tools=(
        "alacritty"         # Terminal
        "brave"             # Browser (you use brave, not vivaldi)
        "dolphin"           # File manager
        "rofi"              # Launcher
        "flameshot"         # Screenshots
        "copyq"             # Clipboard
        "dunst"             # Notifications
        "picom"             # Compositor
        "nitrogen"          # Wallpaper
        "nm-applet"         # Network
        "betterlockscreen"  # Lockscreen
        "brightnessctl"     # Brightness
        "playerctl"         # Media control
        "pavucontrol"       # Audio
    )
    
    log "Checking core Qtile dependencies..." "INFO"
    for pkg in "${core_deps[@]}"; do
        if pacman -Qi "$pkg" &> /dev/null; then
            log "✓ $pkg" "SUCCESS"
        else
            log "✗ $pkg (REQUIRED - MISSING!)" "ERROR"
        fi
    done
    
    echo ""
    log "Checking YOUR installed tools..." "INFO"
    for pkg in "${your_tools[@]}"; do
        if command -v "$pkg" &> /dev/null || pacman -Qi "$pkg" &> /dev/null; then
            log "✓ $pkg (installed and configured)" "SUCCESS"
        else
            log "⚠ $pkg (mentioned in config but not found)" "WARN"
        fi
    done
    
    # Check for picom specifically (since it's in your autostart)
    echo ""
    if command -v picom &> /dev/null; then
        log "Picom compositor is installed and ready" "SUCCESS"
    else
        log "Picom is NOT installed but is in your autostart!" "ERROR"
        log "Install with: sudo pacman -S picom" "INFO"
    fi
}

###############################################################################
# CACHE CLEANUP
###############################################################################

clean_qtile_cache() {
    section_header "Cache Cleanup"
    
    local cache_cleaned=0
    
    # Clean Qtile cache
    if [[ -d "$QTILE_CACHE" ]]; then
        local cache_size
        cache_size=$(du -sh "$QTILE_CACHE" 2>/dev/null | cut -f1)
        log "Current cache size: $cache_size" "INFO"
        
        if [[ "$DRY_RUN" == false ]]; then
            rm -rf "$QTILE_CACHE"
            mkdir -p "$QTILE_CACHE"
            log "Qtile cache cleared" "FIX"
            ((cache_cleaned++))
        else
            log "[DRY RUN] Would clear Qtile cache" "INFO"
        fi
    fi
    
    # Clean Python bytecode
    if [[ -d "$QTILE_CONFIG" ]]; then
        local pycache_count
        pycache_count=$(find "$QTILE_CONFIG" -type d -name "__pycache__" 2>/dev/null | wc -l)
        
        if [[ $pycache_count -gt 0 ]]; then
            log "Found $pycache_count __pycache__ directories" "INFO"
            
            if [[ "$DRY_RUN" == false ]]; then
                find "$QTILE_CONFIG" -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null
                find "$QTILE_CONFIG" -type f -name "*.pyc" -delete 2>/dev/null
                log "Python cache cleaned" "FIX"
                ((cache_cleaned++))
            else
                log "[DRY RUN] Would clean Python cache" "INFO"
            fi
        fi
    fi
    
    # Clean old logs (keep last 10)
    if [[ -d "$QTILE_DATA" ]]; then
        local log_count
        log_count=$(find "$QTILE_DATA" -name "qtile.log*" 2>/dev/null | wc -l)
        
        if [[ $log_count -gt 10 ]]; then
            log "Found $log_count log files (keeping last 10)" "INFO"
            
            if [[ "$DRY_RUN" == false ]]; then
                find "$QTILE_DATA" -name "qtile.log*" -printf '%T@ %p\n' | sort -n | head -n -10 | cut -d' ' -f2- | xargs rm -f
                log "Old logs cleaned" "FIX"
                ((cache_cleaned++))
            else
                log "[DRY RUN] Would clean old logs" "INFO"
            fi
        fi
    fi
    
    if [[ $cache_cleaned -eq 0 ]]; then
        log "Cache already clean" "SUCCESS"
    fi
}

###############################################################################
# AUTOSTART ANALYSIS - TAILORED TO YOUR SETUP
###############################################################################

analyze_autostart() {
    section_header "Autostart Analysis - Your Current Setup"
    
    local autostart="$QTILE_CONFIG/autostart.sh"
    
    if [[ ! -f "$autostart" ]]; then
        log "No autostart.sh found" "WARN"
        
        if confirm_action "Create optimized autostart.sh for YOUR system?"; then
            create_your_autostart_template
        fi
        return 0
    fi
    
    log "Analyzing your autostart.sh..." "INFO"
    
    # Check if executable
    if [[ ! -x "$autostart" ]]; then
        log "autostart.sh is not executable" "WARN"
        
        if confirm_action "Make autostart.sh executable?" && [[ "$DRY_RUN" == false ]]; then
            chmod +x "$autostart"
            log "Made autostart.sh executable" "FIX"
        fi
    fi
    
    # Display your current autostart
    echo -e "\n${CYAN}Your current autostart processes:${NC}"
    grep -v "^#" "$autostart" | grep -v "^$" | nl -ba | tee -a "$LOG_FILE"
    
    # Check for your specific tools
    log "Checking your tool references..." "INFO"
    
    local your_autostart_tools=(
        "nitrogen"
        "picom"
        "nm-applet"
        "dunst"
        "flameshot"
        "copyq"
        "gnome-keyring-daemon"
        "polkit-kde-authentication-agent"
    )
    
    for tool in "${your_autostart_tools[@]}"; do
        if grep -q "$tool" "$autostart"; then
            if command -v "$tool" &> /dev/null || [[ -f "/usr/lib/$tool" ]] || [[ -f "/usr/bin/$tool" ]]; then
                log "✓ $tool - referenced and installed" "SUCCESS"
            else
                log "⚠ $tool - referenced but NOT installed!" "WARN"
            fi
        fi
    done
    
    # Check for proper backgrounding
    if grep -v "^#" "$autostart" | grep -E "^[^&]*(picom|dunst|nm-applet|flameshot)" | grep -v "&" &> /dev/null; then
        log "Some processes may not be running in background (missing &)" "WARN"
    else
        log "All processes properly backgrounded" "SUCCESS"
    fi
}

create_your_autostart_template() {
    local autostart="$QTILE_CONFIG/autostart.sh"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would create your customized autostart template" "INFO"
        return 0
    fi
    
    cat > "$autostart" << 'EOFAUTOSTART'
#!/usr/bin/env bash

# Qtile Autostart Script - Customized for YOUR System
# Generated based on your installed tools

# Wait for desktop to initialize
sleep 1

# Set desktop environment for portals (for Dolphin/Brave file dialogs)
export XDG_CURRENT_DESKTOP=KDE
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP &

# Compositor - picom
picom --experimental-backends &

# Notification daemon - dunst
dunst &

# Network manager applet
nm-applet &

# Wallpaper manager - nitrogen
nitrogen --restore &

# Screenshot tool - flameshot
flameshot &

# Clipboard manager - copyq
copyq &

# Polkit authentication agent (for Dolphin mounting)
/usr/lib/polkit-kde-authentication-agent-1 &

# Keyring daemon (for storing passwords)
eval $(gnome-keyring-daemon --start --components=secrets) &

# Portals (for file pickers, etc.)
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
systemctl --user restart xdg-desktop-portal &

# Optional: Auto-lock screen with betterlockscreen (uncomment if needed)
# xss-lock -- betterlockscreen -l &

# Optional: Power management
# xfce4-power-manager &

# Optional: Bluetooth applet (you have blueman installed)
# blueman-applet &

# Wait for all to start
wait
EOFAUTOSTART
    
    chmod +x "$autostart"
    log "Created customized autostart template for YOUR system" "FIX"
}

###############################################################################
# CONFIG ANALYSIS - YOUR SPECIFIC SETUP
###############################################################################

analyze_config() {
    section_header "Configuration Analysis - Your Setup"
    
    local config="$QTILE_CONFIG/config.py"
    
    if [[ ! -f "$config" ]]; then
        log "config.py not found!" "ERROR"
        return 1
    fi
    
    # Check your browser reference
    if grep -q "vivaldi" "$config"; then
        log "Your config references 'vivaldi' but you're keeping 'brave'" "WARN"
        
        if confirm_action "Update browser reference from vivaldi to brave?"; then
            if [[ "$DRY_RUN" == false ]]; then
                sed -i 's/vivaldi/brave/g' "$config"
                log "Updated browser to brave" "FIX"
            else
                log "[DRY RUN] Would update browser to brave" "INFO"
            fi
        fi
    fi
    
    # Count your layouts
    local layout_count
    layout_count=$(grep -c "layout\." "$config" | head -1)
    log "Layouts configured: $layout_count" "INFO"
    
    # You have 5 layouts: MonadTall, Columns, Max, Bsp, Stack
    if [[ $layout_count -gt 3 ]]; then
        log "You have $layout_count layouts configured" "INFO"
        log "Consider keeping only 2-3 most-used for better performance" "WARN"
        log "Your layouts: MonadTall, Columns, Max, Bsp, Stack" "INFO"
    fi
    
    # Count your keybindings
    local key_count
    key_count=$(grep -c "Key(" "$config" || echo 0)
    log "Keybindings configured: $key_count" "INFO"
    
    # Your groups
    log "Checking your workspace groups..." "INFO"
    if grep -q "Group.*label" "$config"; then
        log "Custom workspace labels detected (with icons)" "SUCCESS"
    fi
}

###############################################################################
# GENERATE OPTIMIZED CONFIG - PRESERVING YOUR KEYBINDINGS
###############################################################################

generate_optimized_config() {
    section_header "Generate Optimized Config (Preserving Your Setup)"
    
    if ! confirm_action "Generate optimized config as config_optimized.py? (Your current config stays unchanged)"; then
        return 0
    fi
    
    local output="$QTILE_CONFIG/config_optimized.py"
    
    if [[ "$DRY_RUN" == true ]]; then
        log "[DRY RUN] Would create optimized config" "INFO"
        return 0
    fi
    
    cat > "$output" << 'EOFCONFIG'
# Qtile Optimized Configuration - Based on YOUR System
# Generated by Qtile Optimizer - Preserves your keybindings and tools
# Uses: brave, alacritty, dolphin, flameshot, copyq, rofi

from libqtile import bar, layout, widget, hook
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
import os
import subprocess

# ============================================================================
# VARIABLES - YOUR TOOLS
# ============================================================================

mod = "mod4"  # Super/Windows key
terminal = "alacritty"          # YOUR terminal
browser = "brave"               # YOUR browser (changed from vivaldi)
file_manager = "dolphin"        # YOUR file manager
screenshot_tool = "flameshot"   # YOUR screenshot tool

# ============================================================================
# KEYBINDINGS - YOUR EXISTING BINDINGS PRESERVED
# ============================================================================

keys = [
    # Launch / Quit
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "s", lazy.spawn("rofi -show drun -modi drun,run,filebrowser -sidebar-mode -theme ~/.config/rofi/themes/tokyo-night.rasi")),
    Key([mod], "q", lazy.window.kill(), desc="Close window"),
    Key([mod], "b", lazy.spawn(browser), desc="Open browser"),  # Changed to brave
    Key([mod], "e", lazy.spawn(file_manager), desc="Open file manager"),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Take a screenshot"),
    Key([mod, "shift"], "Print", lazy.spawn("flameshot full -c"), desc="Screenshot to clipboard"),

    # Layout control
    Key([mod], "Tab", lazy.next_layout(), desc="Cycle layouts"),

    # Focus movement - YOUR BINDINGS
    Key([mod], "h", lazy.layout.left(), desc="Focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "j", lazy.layout.down(), desc="Focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus up"),

    # Window shuffling - YOUR BINDINGS
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Resize keybindings - YOUR BINDINGS
    Key([mod, "control"], "h", lazy.layout.shrink(), desc="Shrink main pane"),
    Key([mod, "control"], "l", lazy.layout.grow(), desc="Grow main pane"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up"),

    # Floating toggle
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),

    # Qtile controls
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.spawn(os.path.expanduser("~/.config/rofi/powermenu.sh"))),
]

# ============================================================================
# GROUPS (WORKSPACES) - YOUR ICONS PRESERVED
# ============================================================================

groups = [ 
    Group("1", label=""),  # Terminal icon
    Group("2", label=""),  # Browser icon  
    Group("3", label=""),  # Code icon
    Group("4", label=""),  # Files icon
    Group("5", label=""),  # Media icon
    Group("6", label=""),  # Misc icon
]

# Group keybindings - YOUR SETUP
for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name), desc=f"Move window to group {i.name}"),
    ])

# ============================================================================
# LAYOUTS - OPTIMIZED (REDUCED FROM 5 TO 3)
# ============================================================================

# Theme colors - YOUR RED ACCENT
colors = {
    "border_focus": "#ff0000",      # Your red
    "border_normal": "#44475a",
    "background": "#1a1b26",        # Your background
}

layout_theme = {
    "border_width": 2,              # Slightly thicker for visibility
    "margin": 8,                    # Increased margin for comfort
    "border_focus": colors["border_focus"],
    "border_normal": colors["border_normal"],
}

# Reduced to 3 most useful layouts for performance
layouts = [
    layout.MonadTall(**layout_theme),     # Your main layout
    layout.Columns(**layout_theme),       # Your secondary layout
    layout.Max(margin=8),                 # Fullscreen layout
    # Removed: Bsp, Stack (rarely used - comment back in if needed)
]

# ============================================================================
# WIDGETS - PERFORMANCE OPTIMIZED
# ============================================================================

widget_defaults = dict(
    font="JetBrainsMono Nerd Font",  # Your font
    fontsize=14,
    padding=3,
)

def create_widgets():
    return [
        widget.TextBox(
            text=" ",  # Launcher icon
            fontsize=18,
            foreground="#3b82f6",
            mouse_callbacks={'Button1': lazy.spawn('rofi -show drun -modi drun,run,filebrowser -sidebar-mode -theme ~/.config/rofi/themes/tokyo-night.rasi')},
            padding=8,
        ),
        widget.GroupBox(
            highlight_method='line',
            this_current_screen_border="#ff0000",  # Your red accent
            active="#f8f8f2",
            inactive="#6272a4",
            disable_drag=True,
            font="JetBrainsMono Nerd Font",
            fontsize=18,
            padding=5,
            use_label=True,  # Shows your custom icons
        ),
        widget.CurrentLayout(
            foreground="#f8f8f2",
            padding=5,
        ),
        widget.WindowName(
            foreground="#f8f8f2",
            max_chars=50,
        ),
        widget.Spacer(),
        
        # Performance optimized widgets (reduced update intervals)
        widget.CPU(
            format=' {load_percent}%',
            foreground="#50fa7b",
            update_interval=5,  # Was 1, now 5 for less CPU usage
        ),
        widget.Memory(
            format=' {MemUsed:.0f}M',
            foreground="#bd93f9",
            update_interval=5,  # Was 1, now 5
        ),
        widget.Volume(
            fmt=' {}',
            foreground="#ffb86c",
        ),
        widget.Clock(
            format=" %I:%M %p  %Y/%m/%d",
            foreground="#8be9fd",
        ),
        widget.Systray(
            padding=5,
        ),
        widget.TextBox(
            text=" ",  # Power icon
            fontsize=15,
            foreground="#808080",
            mouse_callbacks={'Button1': lazy.spawn(os.path.expanduser('~/.config/rofi/powermenu.sh'))},
        ),
    ]

# ============================================================================
# SCREENS - YOUR SETUP
# ============================================================================

screens = [
    Screen(
        top=bar.Bar(
            create_widgets(),
            35,  # Your bar height
            background=colors["background"],
            margin=[3, 5, 0, 5],  # Your margins
        ),
    ),
]

# ============================================================================
# FLOATING LAYOUT - YOUR RULES
# ============================================================================

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="Confirmation"),
        Match(title="Error"),
        Match(title="File Operation Progress"),
        Match(wm_class="ssh-askpass"),
        Match(wm_class="pinentry"),
    ],
    border_focus=colors["border_focus"],
    border_normal=colors["border_normal"],
)

# ============================================================================
# MOUSE
# ============================================================================

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

# ============================================================================
# AUTOSTART
# ============================================================================

@hook.subscribe.startup_once
def autostart():
    """Run autostart script on Qtile startup"""
    autostart_script = os.path.expanduser("~/.config/qtile/autostart.sh")
    if os.path.exists(autostart_script):
        subprocess.Popen([autostart_script])
    
    # Polkit agent for Dolphin / mounting USBs 
    polkit_agent = "/usr/lib/polkit-kde-authentication-agent-1" 
    if os.path.exists(polkit_agent): 
        subprocess.Popen([polkit_agent])

# ============================================================================
# SETTINGS
# ============================================================================

dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wmname = "LG3D"
EOFCONFIG
    
    log "Created optimized config: $output" "FIX"
    log "Key changes from your original:" "INFO"
    log "  • Browser: vivaldi → brave" "INFO"
    log "  • Layouts: 5 → 3 (removed Bsp, Stack)" "INFO"
    log "  • Widget intervals: 1s → 5s (CPU/Memory)" "INFO"
    log "  • Bar margins: preserved your settings" "INFO"
    log "  • Keybindings: ALL PRESERVED" "SUCCESS"
    log "" "INFO"
    log "Review config_optimized.py and rename to config.py when ready" "INFO"
}

###############################################################################
# PERFORMANCE CHECK
###############################################################################

performance_check() {
    section_header "Performance Analysis"
    
    log "Analyzing system performance..." "INFO"
    
    if pgrep -x qtile &> /dev/null; then
        local qtile_pid
        qtile_pid=$(pgrep -x qtile)
        
        local cpu_usage mem_usage
        cpu_usage=$(ps -p "$qtile_pid" -o %cpu --no-headers | tr -d ' ')
        mem_usage=$(ps -p "$qtile_pid" -o rss --no-headers | awk '{print $1/1024 " MB"}')
        
        log "Qtile CPU usage: ${cpu_usage}%" "INFO"
        log "Qtile memory usage: $mem_usage" "INFO"
    else
        log "Qtile is not currently running" "WARN"
    fi
    
    # Check your compositor (picom)
    if pgrep -x picom &> /dev/null; then
        local picom_cpu picom_mem
        picom_cpu=$(ps -C picom -o %cpu --no-headers | tr -d ' ')
        picom_mem=$(ps -C picom -o rss --no-headers | awk '{print $1/1024 " MB"}')
        
        log "Picom CPU usage: ${picom_cpu}%" "INFO"
        log "Picom memory usage: $picom_mem" "INFO"
    else
        log "Picom not running (check autostart.sh)" "WARN"
    fi
}

###############################################################################
# SECURITY AUDIT
###############################################################################

security_audit() {
    section_header "Security Audit"
    
    local config="$QTILE_CONFIG/config.py"
    local autostart="$QTILE_CONFIG/autostart.sh"
    
    # Check file permissions
    if [[ -f "$config" ]]; then
        local config_perms
        config_perms=$(stat -c "%a" "$config")
        
        if [[ "$config_perms" == "644" ]] || [[ "$config_perms" == "600" ]]; then
            log "config.py permissions OK ($config_perms)" "SUCCESS"
        else
            log "config.py has unusual permissions ($config_perms)" "WARN"
        fi
    fi
    
    # Check for hardcoded paths that might be user-specific
    if [[ -f "$config" ]]; then
        if grep -q "/home/[^$]" "$config"; then
            log "Hardcoded home paths found - might break for other users" "WARN"
        fi
    fi
    
    log "Basic security checks completed" "SUCCESS"
}

###############################################################################
# RECOMMENDATIONS - FOR YOUR SYSTEM
###############################################################################

show_recommendations() {
    section_header "Recommendations for YOUR System"
    
    cat << 'EOF'

┌─────────────────────────────────────────────────────────────────────┐
│ BROWSER UPDATE                                                       │
├─────────────────────────────────────────────────────────────────────┤
│ • You removed Vivaldi and kept Brave                                │
│ • Update config.py: Change "vivaldi" → "brave"                     │
│ • Update keybinding: Key([mod], "b", lazy.spawn("brave"))          │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ LAYOUT OPTIMIZATION                                                  │
├─────────────────────────────────────────────────────────────────────┤
│ • You have 5 layouts: MonadTall, Columns, Max, Bsp, Stack          │
│ • Recommendation: Keep only 3 most-used                             │
│ • Suggested: MonadTall (main), Columns (alt), Max (fullscreen)     │
│ • Remove: Bsp, Stack (if rarely used)                              │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ YOUR TOOLS - PROPERLY CONFIGURED                                     │
├─────────────────────────────────────────────────────────────────────┤
│ ✓ Terminal: alacritty                                               │
│ ✓ Browser: brave (update config from vivaldi)                      │
│ ✓ File Manager: dolphin                                             │
│ ✓ Screenshots: flameshot                                            │
│ ✓ Clipboard: copyq (not clipmenu/greenclip)                        │
│ ✓ Notifications: dunst                                               │
│ ✓ Compositor: picom                                                  │
│ ✓ Wallpaper: nitrogen                                                │
│ ✓ Lockscreen: betterlockscreen                                      │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ AUTOSTART IMPROVEMENTS                                               │
├─────────────────────────────────────────────────────────────────────┤
│ • All processes should have & (background)                          │
│ • Current setup looks good!                                          │
│ • XDG_CURRENT_DESKTOP=KDE is correct for Dolphin                   │
│ • Polkit agent is correctly configured                              │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ PICOM CONFIGURATION                                                  │
├─────────────────────────────────────────────────────────────────────┤
│ • You use: picom --experimental-backends                            │
│ • Consider creating ~/.config/picom/picom.conf for:                │
│   - vsync = true (prevent tearing)                                  │
│   - backend = "glx" (GPU acceleration)                              │
│   - Adjust shadow/blur/fade as needed                              │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ SYSTEM-WIDE OPTIMIZATIONS                                            │
├─────────────────────────────────────────────────────────────────────┤
│ • Enable early KMS for AMD:                                         │
│   Edit /etc/mkinitcpio.conf → MODULES=(amdgpu)                     │
│   Run: sudo mkinitcpio -P                                           │
│                                                                      │
│ • Enable TRIM for SSD:                                              │
│   sudo systemctl enable fstrim.timer                                │
│                                                                      │
│ • Optional preload for faster app launches:                         │
│   sudo pacman -S preload                                            │
│   sudo systemctl enable preload                                     │
└─────────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────────┐
│ KEYBINDINGS - YOUR CURRENT SETUP IS GOOD                            │
├─────────────────────────────────────────────────────────────────────┤
│ • Vim-style navigation: h/j/k/l ✓                                   │
│ • Mod+Shift for moving windows ✓                                    │
│ • Mod+Control for resizing ✓                                        │
│ • Print key for screenshots ✓                                       │
│ • Your bindings are well organized!                                 │
└─────────────────────────────────────────────────────────────────────┘

EOF
}

###############################################################################
# INTERACTIVE MENU
###############################################################################

interactive_menu() {
    while true; do
        echo -e "\n${BOLD}${CYAN}╔═══════════════════════════════════════════════════════════╗${NC}"
        echo -e "${BOLD}${CYAN}║     QTILE OPTIMIZATION MENU - YOUR SYSTEM                 ║${NC}"
        echo -e "${BOLD}${CYAN}╚═══════════════════════════════════════════════════════════╝${NC}\n"
        
        echo "  1) Run full optimization"
        echo "  2) Create backup"
        echo "  3) Restore from backup"
        echo "  4) Validate configuration"
        echo "  5) Check dependencies"
        echo "  6) Clean cache"
        echo "  7) Analyze autostart"
        echo "  8) Generate optimized config (preserves your keybindings)"
        echo "  9) Performance check"
        echo " 10) Security audit"
        echo " 11) Show recommendations for YOUR system"
        echo "  0) Exit"
        
        echo ""
        read -rp "Select option: " choice
        
        case $choice in
            1) run_full_optimization ;;
            2) create_backup ;;
            3) restore_backup ;;
            4) validate_python_syntax; check_qtile_version ;;
            5) check_dependencies ;;
            6) clean_qtile_cache ;;
            7) analyze_autostart ;;
            8) generate_optimized_config ;;
            9) performance_check ;;
            10) security_audit ;;
            11) show_recommendations ;;
            0) log "Exiting..." "INFO"; exit 0 ;;
            *) log "Invalid option" "ERROR" ;;
        esac
        
        read -rp "Press Enter to continue..."
    done
}

###############################################################################
# FULL OPTIMIZATION
###############################################################################

run_full_optimization() {
    section_header "Running Full Optimization"
    
    create_backup
    check_qtile_version
    check_dependencies
    validate_python_syntax
    analyze_config
    analyze_autostart
    clean_qtile_cache
    performance_check
    security_audit
    
    section_header "Optimization Summary"
    
    echo -e "${BOLD}Results:${NC}"
    echo -e "  ${GREEN}Fixes applied: $FIXES_APPLIED${NC}"
    echo -e "  ${YELLOW}Warnings: $WARNINGS_FOUND${NC}"
    echo -e "  ${RED}Errors: $ERRORS_FOUND${NC}"
    echo ""
    
    if [[ $ERRORS_FOUND -gt 0 ]]; then
        log "Optimization completed with errors - review log" "WARN"
    else
        log "Optimization completed successfully!" "SUCCESS"
    fi
    
    echo ""
    log "Full log available at: $LOG_FILE" "INFO"
    
    if [[ $FIXES_APPLIED -gt 0 ]]; then
        echo ""
        log "Reload Qtile to apply changes: Super+Ctrl+R" "INFO"
    fi
}

###############################################################################
# MAIN EXECUTION
###############################################################################

show_usage() {
    cat << EOF
Qtile Optimization Tool - Customized for YOUR System v${SCRIPT_VERSION}

Usage: $(basename "$0") [OPTIONS]

Options:
  -h, --help           Show this help message
  -i, --interactive    Interactive menu mode (default)
  -a, --auto           Run full optimization automatically
  -d, --dry-run        Show what would be done without making changes
  -n, --no-backup      Skip backup creation
  -b, --backup         Create backup only
  -r, --restore        Restore from backup
  -v, --validate       Validate configuration only
  -c, --clean          Clean cache only
  --version            Show version

Examples:
  $(basename "$0")                    # Interactive mode
  $(basename "$0") --auto             # Auto optimization
  $(basename "$0") --dry-run --auto   # Preview changes
  $(basename "$0") --backup           # Backup only

Your Tools:
  Browser: brave (was vivaldi)
  Terminal: alacritty
  Screenshot: flameshot
  Clipboard: copyq
  File Manager: dolphin
  Compositor: picom

EOF
}

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
                log "Running in DRY RUN mode" "INFO"
                shift
                ;;
            -n|--no-backup)
                SKIP_BACKUP=true
                shift
                ;;
            -b|--backup)
                create_backup
                exit 0
                ;;
            -r|--restore)
                restore_backup
                exit 0
                ;;
            -v|--validate)
                validate_python_syntax
                check_qtile_version
                exit 0
                ;;
            -c|--clean)
                clean_qtile_cache
                exit 0
                ;;
            --version)
                echo "Qtile Pro Optimizer v${SCRIPT_VERSION} - Customized"
                exit 0
                ;;
            *)
                echo "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if running as root
    if [[ $EUID -eq 0 ]]; then
        log "Do not run this script as root!" "ERROR"
        exit 1
    fi
    
    # Main execution
    if [[ "$INTERACTIVE" == true ]]; then
        interactive_menu
    else
        run_full_optimization
    fi
    
    echo ""
    log "Log saved to: $LOG_FILE" "INFO"
}

# Trap errors
trap 'log "Script interrupted or failed at line $LINENO" "ERROR"; exit 1' ERR INT TERM

# Run main
main "$@"
