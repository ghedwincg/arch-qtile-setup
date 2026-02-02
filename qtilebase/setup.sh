#!/bin/bash
################################################################################
# Arch + Qtile Default Config Deployer
# Purpose: Deploy baseline configs for Qtile, Dunst, Picom, Rofi, Dolphin, etc.
# Plus defaults for Zsh, Kitty, Alacritty, Neovim, Nitrogen.
# Philosophy: Valve-style reliability — catch errors, log them, never stop.
################################################################################

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; NC='\033[0m'
ERROR_LOG="/tmp/config_errors.log"; > "$ERROR_LOG"

print_section() { echo -e "\n${GREEN}▶ $1${NC}\n"; }
print_success() { echo -e "${GREEN}[✓]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[!]${NC} $1"; }
print_error() { echo -e "${RED}[✗]${NC} $1"; }

safe_write() {
    local target="$1"
    local content="$2"
    if echo "$content" > "$target"; then
        print_success "Wrote $target"
    else
        print_error "Failed to write $target"
        echo "$(date '+%F %T') - $target" >> "$ERROR_LOG"
    fi
}

mkdir -p "$HOME/.config/qtile" "$HOME/.config/dunst" "$HOME/.config/picom" \
         "$HOME/.config/rofi" "$HOME/.local/bin" "$HOME/.config/kitty" \
         "$HOME/.config/alacritty" "$HOME/.config/nvim" "$HOME/.config/nitrogen"

################################################################################
# Qtile config.py
################################################################################
print_section "Qtile Config"
safe_write "$HOME/.config/qtile/config.py" "$(cat <<'EOF'
from libqtile import layout, bar, widget, hook
from libqtile.config import Key, Screen, Group
from libqtile.lazy import lazy

mod = "mod4"
terminal = "kitty"

keys = [
    Key([mod], "Return", lazy.spawn(terminal)),
    Key([mod], "d", lazy.spawn("rofi -show drun")),
    Key([mod], "q", lazy.window.kill()),
    Key([mod], "r", lazy.reload_config()),
]

groups = [Group(i) for i in "123456"]

layouts = [layout.MonadTall(), layout.Max()]

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.GroupBox(),
                widget.Prompt(),
                widget.WindowName(),
                widget.Systray(),
                widget.Clock(format="%Y-%m-%d %H:%M"),
            ],
            24,
        ),
    ),
]

@hook.subscribe.startup_once
def autostart():
    import subprocess
    subprocess.Popen(["~/.config/qtile/autostart.sh"])
EOF
)"

################################################################################
# Autostart script
################################################################################
print_section "Qtile Autostart"
safe_write "$HOME/.config/qtile/autostart.sh" "$(cat <<'EOF'
#!/bin/bash
nitrogen --restore &
copyq &
flameshot &
EOF
)"
chmod +x "$HOME/.config/qtile/autostart.sh"

################################################################################
# Dunst config
################################################################################
print_section "Dunst Config"
safe_write "$HOME/.config/dunst/dunstrc" "$(cat <<'EOF'
[global]
geometry = "300x50-10+40"
font = JetBrainsMono Nerd Font 10
frame_width = 2
frame_color = "#1a1b26"
background = "#1a1b26"
foreground = "#c0caf5"
separator_color = "#7aa2f7"
EOF
)"

################################################################################
# Bash profile
################################################################################
print_section "Bash Profile"
safe_write "$HOME/.bash_profile" "$(cat <<'EOF'
[[ -f ~/.bashrc ]] && . ~/.bashrc
export TERMINAL=kitty
export BROWSER=brave
export EDITOR=nvim

# Start Xorg automatically on login
if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    exec startx
fi
EOF
)"

################################################################################
# Zsh config
################################################################################
print_section "Zsh Config"
safe_write "$HOME/.zshrc" "$(cat <<'EOF'
# Enable plugins
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

# Prompt
PROMPT='%F{cyan}%n@%m%f %F{yellow}%~%f %# '
EOF
)"

################################################################################
# Kitty config
################################################################################
print_section "Kitty Config"
safe_write "$HOME/.config/kitty/kitty.conf" "$(cat <<'EOF'
font_family JetBrainsMono Nerd Font
font_size 12.0
background #1a1b26
foreground #c0caf5
cursor #7aa2f7
EOF
)"

################################################################################
# Alacritty config
################################################################################
print_section "Alacritty Config"
safe_write "$HOME/.config/alacritty/alacritty.yml" "$(cat <<'EOF'
font:
  normal:
    family: JetBrainsMono Nerd Font
    style: Regular
  size: 12.0

colors:
  primary:
    background: '#1a1b26'
    foreground: '#c0caf5'
  cursor:
    text: '#1a1b26'
    cursor: '#7aa2f7'
EOF
)"

################################################################################
# Neovim config
################################################################################
print_section "Neovim Config"
safe_write "$HOME/.config/nvim/init.vim" "$(cat <<'EOF'
set number
set relativenumber
syntax on
set tabstop=4 shiftwidth=4 expandtab
set clipboard=unnamedplus
colorscheme default
EOF
)"

################################################################################
# Nitrogen wallpaper config
################################################################################
print_section "Nitrogen Config"
safe_write "$HOME/.config/nitrogen/bg-saved.cfg" "$(cat <<'EOF'
[xin_-1]
file=/usr/share/backgrounds/archlinux/simple.png
mode=0
bgcolor=#000000
EOF
)"

################################################################################
# Xinitrc
################################################################################
print_section "Xinitrc"
safe_write "$HOME/.xinitrc" "$(cat <<'EOF'
#!/bin/bash
xrdb -merge ~/.Xresources
picom --config ~/.config/picom/picom.conf &
dunst &
nm-applet &
blueman-applet &
exec qtile
EOF
)"
chmod +x "$HOME/.xinitrc"

################################################################################
# Picom config
################################################################################
print_section "Picom Config"
safe_write "$HOME/.config/picom/picom.conf" "$(cat <<'EOF'
backend = "glx";
vsync = true;

shadow = true;
shadow-radius = 12;
shadow-opacity = 0.35;

fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;

inactive-opacity = 0.90;
active-opacity = 1.0;

corner-radius = 8;

blur-method = "dual_kawase";
blur-strength = 6;
blur-background-exclude = [
  "class_g = 'Polybar'",
  "class_g = 'Rofi'",
  "class_g = 'Dunst'"
];
EOF
)"

################################################################################
# Dolphin MIME defaults
################################################################################
print_section "Dolphin MIME Defaults"
safe_write "$HOME/.config/mimeapps.list" "$(cat <<'EOF'
[Default Applications]
text/plain=nvim.desktop
image/png=gimp.desktop
image/jpeg=gimp.desktop
application/pdf=zathura.desktop
video/mp4=mpv.desktop
audio/mpeg=vlc.desktop
EOF
)"

################################################################################
# Power menu scripts
################################################################################
print_section "Powermenu"
safe_write "$HOME/.local/bin/powermenu.sh" "$(cat <<'EOF'
#!/bin/bash
rofi -show power -modi "power:~/.local/bin/rofi-power.sh"
EOF
)"
chmod +x "$HOME/.local/bin/powermenu.sh"

safe_write "$HOME/.local/bin/rofi-power.sh" "$(cat <<'EOF'
#!/bin/bash
echo -e "Shutdown\nReboot\nLogout" | rofi -dmenu -p "Power" | while read -r option; do
    case $option in
        Shutdown) systemctl poweroff ;;
        Reboot) systemctl reboot ;;
        Logout) qtile cmd-obj -o cmd -f shutdown ;;
    esac
done
EOF
)"
chmod +x "$HOME/.local/bin/rofi-power.sh"

################################################################################
# Rofi theme
################################################################################
print_section "Rofi Theme"
safe_write "$HOME/.config/rofi/config.rasi" "$(cat <<'EOF'
configuration {
    font: "JetBrainsMono Nerd Font 12";
    theme: "tokyonight";
}
EOF
)"

################################################################################
# Summary
################################################################################
print_section "SUMMARY" 
if [[ -s "$ERROR_LOG" ]]; then 
    print_warning "Some configs failed:" 
    cat "$ERROR_LOG" 
else 
    print_success "All configs deployed successfully!" 
fi
