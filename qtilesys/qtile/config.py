from libqtile import bar, layout, widget, hook
from libqtile.config import Key, Group, Screen, Match
from libqtile.lazy import lazy
import subprocess
import os

mod = "mod4"  # Super/Windows key
terminal = "alacritty"

# --- Keybindings ---
keys = [
    # Launch / Quit
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "s", lazy.spawn("rofi -show drun -modi drun,run,filebrowser -sidebar-mode -theme ~/.config/rofi/themes/tokyo-night.rasi")),
    Key([mod], "q", lazy.window.kill(), desc="Close window"),
    Key([mod], "b", lazy.spawn("vivaldi"), desc="Open browser file manager"),
    Key([mod], "e", lazy.spawn("dolphin"), desc="Open Dolphin file manager"),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Take a screenshot"),
    Key([mod, "shift"], "Print", lazy.spawn("flameshot full -c"), desc="Screenshot directly to clipboard"),

    # Layout control
    Key([mod], "Tab", lazy.next_layout(), desc="Cycle layouts"),

    # Focus movement
    Key([mod], "h", lazy.layout.left(), desc="Focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "j", lazy.layout.down(), desc="Focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus up"),

    # Window shuffling
    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    # Resize keybindings
    Key([mod, "control"], "h", lazy.layout.shrink(), desc="Shrink main pane"),
    Key([mod, "control"], "l", lazy.layout.grow(), desc="Grow main pane"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down (Columns)"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up (Columns)"),

    # Floating toggle
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),

    # Screen Shot
    Key([mod, "shift"], "Print", lazy.spawn("flameshot gui"), desc="Take a screenshot"),
    Key([], "Print", lazy.spawn("flameshot full -c"), desc="Screenshot directly to clipboard"),

    # Restart / Shutdown Qtile
    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.spawn(os.path.expanduser("~/.config/rofi/powermenu.sh"))),
]

# --- Groups ---
groups = [ 
    Group("1", label=""),  
    Group("2", label=""),  
    Group("3", label=""),
    Group("4", label="󰿎"),
    Group("5", label=""),       
    Group("6", label=" "),      
]

# --- Workspace (Group) keybindings ---
for i in groups:
    keys.extend([
        # Switch to workspace N
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        # Move focused window to workspace N
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name), desc=f"Move window to group {i.name}"),
    ])


# --- Layouts ---
layouts = [
    layout.MonadTall(margin=3, border_width=1, border_focus="#ff0000"),
    layout.Columns(margin=3, border_width=1, border_focus="#ff0000"),
    layout.Max(margin=3), # Max usually doesn't need gaps, but this adds them to the edges
    layout.Bsp(margin=3, border_width=1, border_focus="#ff0000"),
    layout.Stack(margin=3, border_width=1),
]
# --- Floating rules ---
floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="Confirmation"),
        Match(title="Error"),
        Match(title="File Operation Progress"),
        Match(wm_class="ssh-askpass"),
        Match(wm_class="pinentry"),
    ]
)

# --- Widgets / Screens ---
widget_defaults = dict(font="Ubuntu", fontsize=14, padding=3)

screens = [
    Screen(
        top=bar.Bar(
            [
            widget.TextBox(
                       text="  ",
                       fontsize=18,
                       foreground="#3b82f6",
                       mouse_callbacks={'Button1': lazy.spawn('rofi -show drun -modi drun,run,filebrowser -sidebar-mode -theme ~/.config/rofi/themes/tokyo-night.rasi')},
                       padding=5, 
),
                widget.GroupBox(
                    highlight_method='line',
                    use_label=True, 
                    font="JetBrainsMono Nerd Font",
                    fontsize=18
                    ),
                widget.CurrentLayout(
                    mode='icon',
                    scale=0.7,
                    padding=5
                ),
                widget.WindowName(),
                widget.Clock(format="  %I:%M %p\n  %Y/%m/%d ",
                             fontsize=12,
                             mouse_callbacks={ 'Button1': lambda: qtile.cmd_spawn("gnome-calendar") },
                             padding=5,),
                widget.TextBox(
                       text="󰂞 ",
                       fontsize=15,
                       foreground="#808080", 
                       #mouse_callbacks={'Button1': lazy.spawn('/home/user/.config/rofi/powermenu.sh')},
                       #padding=10
),
            ],
            35,
            margin=[3, 5, 0, 5], # [top, right, bottom, left] 
            # margin=10,   # Or use a single number for equal gaps on all sides
            background="#1a1b26",
        ),
    ),
]

# --- Autostart hook ---
@hook.subscribe.startup_once
def start_apps():
    subprocess.Popen([os.path.expanduser("~/.config/qtile/autostart.sh")])
    # Polkit agent for Dolphin / mounting USBs 
    polkit_agent = "/usr/lib/polkit-kde-authentication-agent-1" 
    if os.path.exists(polkit_agent): 
        subprocess.Popen([polkit_agent])
