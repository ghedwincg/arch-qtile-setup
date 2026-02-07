# 🚀 ROFI ULTIMATE CONFIGURATION
## Advanced All-in-One Setup for Arch Linux + Qtile

A highly advanced Rofi configuration that combines all features into a single, beautiful window. Perfect for power users who want maximum functionality with minimal window management.

---

## ✨ Features

### 🎯 Main Features (All in One Window)
- **Combi Mode**: Applications, run commands, window switching, and file browsing in a single unified interface
- **Smart Sorting**: Fuzzy matching with FZF algorithm for lightning-fast searches
- **Beautiful UI**: Cyberpunk-inspired theme with glassmorphism effects
- **Icon Support**: Full icon theme integration (Papirus Dark)
- **Window Management**: Quick window switching with live previews

### 🛠️ Utility Menus
- **Power Menu**: Shutdown, reboot, lock, suspend, hibernate, logout
- **Network Manager**: WiFi connection, VPN status, airplane mode
- **Screenshot Tool**: Fullscreen, area selection, window capture, delayed shots
- **Clipboard Manager**: Full clipboard history with search
- **Settings Menu**: Display, audio, bluetooth, keyboard layouts, themes
- **Calculator**: Built-in calculator mode
- **Emoji Picker**: Quick emoji insertion
- **SSH Manager**: Saved SSH connections
- **File Browser**: Navigate filesystem directly from Rofi

---

## 📦 Installation

### Prerequisites
```bash
# Core packages
sudo pacman -S rofi rofi-calc rofi-emoji papirus-icon-theme \
               ttf-jetbrains-mono-nerd xclip maim networkmanager \
               dunst picom

# Optional but recommended
sudo pacman -S clipmenu betterlockscreen arandr pavucontrol \
               blueman lxappearance qt5ct

# AUR packages (using yay)
yay -S rofi-greenclip
```

### Quick Install
```bash
# Make the install script executable
chmod +x install.sh

# Run the installer
./install.sh
```

### Manual Install
```bash
# Create directories
mkdir -p ~/.config/rofi/{themes,scripts}
mkdir -p ~/Pictures/Screenshots

# Copy files
cp config.rasi ~/.config/rofi/
cp *.sh ~/.config/rofi/scripts/
chmod +x ~/.config/rofi/scripts/*.sh
```

---

## ⚙️ Configuration

### Qtile Integration

Add to `~/.config/qtile/config.py`:

```python
from libqtile.config import Key
from libqtile.lazy import lazy

# Modifier key (Super/Windows key)
mod = "mod4"

keys = [
    # === MAIN LAUNCHER (ALL-IN-ONE) ===
    Key([mod], "space", 
        lazy.spawn("rofi -show combi"),
        desc="Rofi all-in-one launcher"),
    
    # === DIRECT ACCESS ===
    Key([mod], "d", 
        lazy.spawn("rofi -show drun"),
        desc="Applications"),
    
    Key([mod], "r", 
        lazy.spawn("rofi -show run"),
        desc="Run command"),
    
    Key([mod], "w", 
        lazy.spawn("rofi -show window"),
        desc="Window switcher"),
    
    Key([mod], "e", 
        lazy.spawn("rofi -show filebrowser"),
        desc="File browser"),
    
    # === UTILITY MENUS ===
    Key([mod], "x", 
        lazy.spawn("~/.config/rofi/scripts/rofi-power-menu.sh"),
        desc="Power menu"),
    
    Key([mod], "v", 
        lazy.spawn("~/.config/rofi/scripts/rofi-clipboard.sh"),
        desc="Clipboard history"),
    
    Key([], "Print", 
        lazy.spawn("~/.config/rofi/scripts/rofi-screenshot.sh"),
        desc="Screenshot menu"),
    
    Key([mod], "n", 
        lazy.spawn("~/.config/rofi/scripts/rofi-network.sh"),
        desc="Network manager"),
    
    Key([mod, "shift"], "s", 
        lazy.spawn("~/.config/rofi/scripts/rofi-settings.sh"),
        desc="Settings menu"),
    
    # === BONUS FEATURES ===
    Key([mod], "c", 
        lazy.spawn("rofi -show calc -modi calc -no-show-match -no-sort"),
        desc="Calculator"),
    
    Key([mod], "period", 
        lazy.spawn("rofi -show emoji -modi emoji"),
        desc="Emoji picker"),
]
```

### Autostart Services

Create `~/.config/qtile/autostart.sh`:

```bash
#!/usr/bin/env bash

# Compositor for transparency
picom -b &

# Notification daemon
dunst &

# Clipboard manager
clipmenud &

# Network manager applet
nm-applet &

# Bluetooth applet
blueman-applet &
```

Add to Qtile config:
```python
import os
import subprocess
from libqtile import hook

@hook.subscribe.startup_once
def autostart():
    home = os.path.expanduser('~/.config/qtile/autostart.sh')
    subprocess.Popen([home])
```

---

## 🎨 Customization

### Color Scheme

Edit `~/.config/rofi/config.rasi` to change colors:

```css
* {
    /* Background colors */
    bg0:     #1e1e2eff;  /* Main background */
    bg1:     #282a36ff;  /* Secondary background */
    bg2:     #44475aff;  /* Tertiary background */
    
    /* Text colors */
    fg0:     #f8f8f2ff;  /* Primary text */
    fg1:     #e0e0e0ff;  /* Secondary text */
    fg2:     #9ca0b0ff;  /* Tertiary text */
    
    /* Accent colors */
    accent:  #bd93f9ff;  /* Primary accent (purple) */
    accent-alt: #ff79c6ff;  /* Alternative accent (pink) */
    urgent:  #ff5555ff;  /* Urgent/error (red) */
    active:  #50fa7bff;  /* Active/success (green) */
}
```

### Pre-made Color Schemes

#### Catppuccin Mocha
```css
bg0:     #1e1e2eff;
bg1:     #313244ff;
accent:  #cba6f7ff;
fg0:     #cdd6f4ff;
```

#### Nord
```css
bg0:     #2e3440ff;
bg1:     #3b4252ff;
accent:  #88c0d0ff;
fg0:     #eceff4ff;
```

#### Gruvbox Dark
```css
bg0:     #282828ff;
bg1:     #3c3836ff;
accent:  #d3869bff;
fg0:     #ebdbb2ff;
```

#### Tokyo Night
```css
bg0:     #1a1b26ff;
bg1:     #24283bff;
accent:  #7aa2f7ff;
fg0:     #c0caf5ff;
```

### Window Dimensions

```css
window {
    width: 1200px;   /* Adjust width */
    height: 700px;   /* Adjust height */
}
```

### Font

```css
* {
    font: "JetBrainsMono Nerd Font 11";
}
```

Popular alternatives:
- `"FiraCode Nerd Font 11"`
- `"Hack Nerd Font 11"`
- `"UbuntuMono Nerd Font 12"`
- `"Cascadia Code 11"`

---

## ⌨️ Default Keybindings

### Main Launcher
| Key | Action |
|-----|--------|
| `Super + Space` | Open all-in-one launcher |
| `Super + D` | Applications only |
| `Super + R` | Run command |
| `Super + W` | Window switcher |
| `Super + E` | File browser |

### Utility Menus
| Key | Action |
|-----|--------|
| `Super + X` | Power menu |
| `Super + V` | Clipboard history |
| `Print` | Screenshot menu |
| `Super + N` | Network manager |
| `Super + Shift + S` | Settings menu |

### Bonus Features
| Key | Action |
|-----|--------|
| `Super + C` | Calculator |
| `Super + .` | Emoji picker |

### Within Rofi
| Key | Action |
|-----|--------|
| `↑/↓` or `Ctrl+P/N` | Navigate |
| `Tab` | Switch modes |
| `Shift + Tab` | Previous mode |
| `Enter` | Select |
| `Shift + Enter` | Alternative action |
| `Ctrl + Enter` | Custom action |
| `Esc` | Close |
| `Delete` | Remove entry |

---

## 🔧 Advanced Features

### Calculator Mode
```bash
rofi -show calc -modi calc -no-show-match -no-sort
```
- Supports: `+`, `-`, `*`, `/`, `^`, `%`, `sqrt()`, `sin()`, `cos()`, etc.
- Results auto-copy to clipboard

### Emoji Picker
```bash
rofi -show emoji -modi emoji
```
- Search by name or keyword
- Click or Enter to insert

### Clipboard Manager

**Using clipmenu:**
```bash
# Start daemon in autostart
clipmenud &

# Use in Rofi
CM_LAUNCHER=rofi clipmenu
```

**Using greenclip:**
```bash
# Start daemon
greenclip daemon &

# Use in Rofi
rofi -modi "clipboard:greenclip print" -show clipboard
```

### File Browser
- Navigate with keyboard
- `Enter`: Open file/enter directory
- `Alt+.`: Show hidden files
- Type to filter

### SSH Manager
Edit `~/.ssh/config` for quick connections:
```
Host myserver
    HostName example.com
    User username
    Port 22
```

Then access via: `rofi -show ssh`

---

## 🐛 Troubleshooting

### Rofi doesn't show icons
```bash
# Install icon theme
sudo pacman -S papirus-icon-theme

# Update icon cache
gtk-update-icon-cache
```

### Clipboard history not working
```bash
# Start clipboard daemon
clipmenud &

# Or use greenclip
greenclip daemon &
```

### Fonts not displaying correctly
```bash
# Install Nerd Fonts
sudo pacman -S ttf-jetbrains-mono-nerd

# Update font cache
fc-cache -fv
```

### Network menu not working
```bash
# Enable NetworkManager
sudo systemctl enable --now NetworkManager
```

### Transparency not working
```bash
# Install and run compositor
sudo pacman -S picom
picom -b
```

### Screenshot tool not working
```bash
# Install screenshot tool (choose one)
sudo pacman -S maim        # Recommended
sudo pacman -S scrot       # Alternative
sudo pacman -S flameshot   # GUI alternative
```

---

## 📁 File Structure

```
~/.config/rofi/
├── config.rasi                 # Main configuration
├── scripts/
│   ├── rofi-launcher.sh        # Master launcher
│   ├── rofi-power-menu.sh      # Power options
│   ├── rofi-clipboard.sh       # Clipboard manager
│   ├── rofi-screenshot.sh      # Screenshot utility
│   ├── rofi-network.sh         # Network manager
│   └── rofi-settings.sh        # Settings menu
└── themes/                     # Custom themes (optional)
```

---

## 🎯 Performance Tips

1. **Reduce icon size** for faster rendering:
   ```css
   element-icon {
       size: 24px;  /* Default is 32px */
   }
   ```

2. **Disable icons** if not needed:
   ```
   configuration {
       show-icons: false;
   }
   ```

3. **Limit file browser depth**:
   ```
   filebrowser {
       depth: 3;  /* Default is infinite */
   }
   ```

4. **Use solid colors** instead of transparency:
   ```css
   window {
       transparency: "screenshot";  /* Instead of "real" */
   }
   ```

---

## 🌟 Pro Tips

1. **Quick Math**: Use calculator mode as a quick calculator
   ```
   Super + C, type "123 * 456", Enter
   ```

2. **Window Management**: Use window mode to quickly switch between workspaces
   ```
   Super + W, type window name
   ```

3. **File Navigation**: Use file browser instead of terminal for quick file access
   ```
   Super + E, navigate with keyboard
   ```

4. **Clipboard Power**: Never lose copied text again
   ```
   Super + V, search through history
   ```

5. **Quick Settings**: Change system settings without opening full apps
   ```
   Super + Shift + S, select setting
   ```

---

## 📝 License

MIT License - Feel free to modify and share!

## 🤝 Contributing

Suggestions and improvements welcome! This is an advanced configuration designed to push Rofi to its limits.

## 📚 Resources

- [Rofi Documentation](https://github.com/davatorium/rofi)
- [Rofi Wiki](https://github.com/davatorium/rofi/wiki)
- [Qtile Documentation](http://docs.qtile.org/)
- [Arch Wiki - Rofi](https://wiki.archlinux.org/title/Rofi)

---

**Enjoy your ultra-powerful Rofi setup! 🚀**
