# 🔋 ROFI POWER MENU - Modern Style

Beautiful power menu with confirmation dialogs, inspired by modern system interfaces.

## ✨ Features

- **5 Power Options**: Lock, Logout, Suspend, Reboot, Shutdown
- **Confirmation Dialogs**: "Are you sure?" prompt for destructive actions
- **Modern UI**: Dark theme with hover effects
- **System Uptime**: Shows current uptime in menu
- **Icon Support**: Nerd Font icons for visual appeal
- **Mouse Support**: Click-to-select or keyboard navigation

## 📦 Installation

### Quick Install
```bash
chmod +x install-powermenu.sh
./install-powermenu.sh
```

### Manual Install
```bash
# Create directories
mkdir -p ~/.config/rofi/themes
mkdir -p ~/.config/rofi/scripts

# Copy files
cp powermenu.rasi ~/.config/rofi/themes/
cp powermenu-confirm.rasi ~/.config/rofi/themes/
cp rofi-powermenu-modern.sh ~/.config/rofi/scripts/rofi-powermenu.sh
chmod +x ~/.config/rofi/scripts/rofi-powermenu.sh
```

## ⚙️ Configuration

### Qtile Keybinding

Add to `~/.config/qtile/config.py`:

```python
from libqtile.config import Key
from libqtile.lazy import lazy

keys = [
    # Power menu
    Key([mod], "x", 
        lazy.spawn(os.path.expanduser("~/.config/rofi/scripts/rofi-powermenu.sh")),
        desc="Power menu"),
]
```

### i3 Keybinding

Add to `~/.config/i3/config`:

```
bindsym $mod+x exec --no-startup-id ~/.config/rofi/scripts/rofi-powermenu.sh
```

## 🎨 Customization

### Change Colors

Edit `~/.config/rofi/themes/powermenu.rasi`:

```css
* {
    background:     #1e1e2eff;  /* Main background */
    background-alt: #282a36ff;  /* Button background */
    foreground:     #f8f8f2ff;  /* Text color */
    active:         #bd93f9ff;  /* Accent color (purple) */
    urgent:         #ff5555ff;  /* Warning color (red) */
}
```

### Popular Color Schemes

#### Catppuccin Mocha
```css
* {
    background:     #1e1e2eff;
    background-alt: #313244ff;
    foreground:     #cdd6f4ff;
    active:         #cba6f7ff;
    urgent:         #f38ba8ff;
}
```

#### Nord
```css
* {
    background:     #2e3440ff;
    background-alt: #3b4252ff;
    foreground:     #eceff4ff;
    active:         #88c0d0ff;
    urgent:         #bf616aff;
}
```

#### Gruvbox Dark
```css
* {
    background:     #282828ff;
    background-alt: #3c3836ff;
    foreground:     #ebdbb2ff;
    active:         #d3869bff;
    urgent:         #fb4934ff;
}
```

#### Tokyo Night
```css
* {
    background:     #1a1b26ff;
    background-alt: #24283bff;
    foreground:     #c0caf5ff;
    active:         #7aa2f7ff;
    urgent:         #f7768eff;
}
```

### Change Icons

Edit `rofi-powermenu-modern.sh`:

```bash
# Default icons
shutdown=" "
reboot=" "
lock=" "
suspend=" "
logout=" "

# Alternative icon sets (uncomment to use)

# Simple text
# shutdown="⏻ Power Off"
# reboot=" Reboot"
# lock=" Lock"
# suspend="⏾ Suspend"
# logout=" Logout"

# Emoji style
# shutdown="⏻"
# reboot="🔄"
# lock="🔒"
# suspend="😴"
# logout="👋"
```

### Change Button Layout

Edit `powermenu.rasi`:

```css
listview {
    columns: 5;  /* Change to 3 for larger buttons */
    lines: 1;    /* Change to 2 for vertical layout */
}
```

### Adjust Window Size

Edit `powermenu.rasi`:

```css
window {
    width: 550px;  /* Make wider/narrower */
}
```

For confirmation dialog, edit `powermenu-confirm.rasi`:

```css
window {
    width: 500px;
}
```

## 🎯 Usage

### Keyboard Navigation
- **Arrow Keys**: Navigate between options
- **Enter**: Select option
- **Escape**: Cancel/close

### Mouse Navigation
- **Hover**: Highlight option
- **Click**: Select option

### Options

| Icon | Action | Confirmation |
|------|--------|--------------|
| 🔒 | Lock screen | No |
| 🚪 | Logout from Qtile | Yes |
| 😴 | Suspend system | Yes |
| 🔄 | Reboot system | Yes |
| ⏻ | Shutdown system | Yes |

## 🔧 Troubleshooting

### Icons not showing
```bash
# Install Nerd Fonts
sudo pacman -S ttf-jetbrains-mono-nerd

# Or install manually
yay -S nerd-fonts-complete
```

### Lock screen not working
```bash
# Install lock screen program
sudo pacman -S betterlockscreen

# Or use i3lock
sudo pacman -S i3lock
```

### Theme not found error
```bash
# Verify theme files exist
ls ~/.config/rofi/themes/powermenu*.rasi

# If missing, copy them again
cp powermenu*.rasi ~/.config/rofi/themes/
```

### Confirmation dialog doesn't show
Make sure both theme files are installed:
- `powermenu.rasi` - Main menu
- `powermenu-confirm.rasi` - Confirmation dialog

### Nothing happens when selecting option
Check if systemctl works:
```bash
# Test (will ask for password)
systemctl status

# Make sure user has permission for poweroff/reboot
# Usually configured in /etc/polkit-1/rules.d/
```

## 📝 File Structure

```
~/.config/rofi/
├── themes/
│   ├── powermenu.rasi          # Main menu theme
│   └── powermenu-confirm.rasi  # Confirmation dialog theme
└── scripts/
    └── rofi-powermenu.sh       # Power menu script
```

## 🎨 Screenshots

The menu shows:
- 5 icon buttons in a row
- System uptime in the prompt
- Dark background with purple accents
- Hover effects on buttons

Confirmation dialog shows:
- Warning message
- "Yes" and "No" buttons
- Same dark theme styling

## 🚀 Advanced Features

### Add Custom Actions

Edit `rofi-powermenu-modern.sh`:

```bash
# Add new option
hibernate=" "

# Add to menu
show_menu() {
    rofi -dmenu \
        -p "Uptime: $uptime_info" \
        -theme "$THEME" \
        ... <<< $''"$lock"$'\n'"$logout"$'\n'"$hibernate"$'\n'"$suspend"$'\n'"$reboot"$'\n'"$shutdown"
}

# Add case
case "$chosen" in
    "$hibernate")
        ans=$(confirm_exit "Hibernate")
        if [[ "$ans" == "Yes" ]]; then
            systemctl hibernate
            exit 0
        fi
        ;;
esac
```

### Change Confirmation Message

Edit the script:

```bash
confirm_exit() {
    local message="$1"
    
    rofi -dmenu \
        -p "$message" \
        -mesg "Your custom message here!" \  # Change this line
        -theme "$CONFIRM_THEME" \
        ...
}
```

## 📚 Resources

- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Nerd Fonts](https://www.nerdfonts.com/)
- [Qtile Documentation](http://docs.qtile.org/)

## 🤝 Credits

Inspired by modern desktop environments and the screenshot you provided!

---

**Enjoy your beautiful power menu! 🎨**
