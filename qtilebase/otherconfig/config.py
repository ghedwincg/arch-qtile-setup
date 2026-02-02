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
    Key([mod], "q", lazy.window.kill(), desc="Close window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),
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

    # Columns-specific resizing
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow window down (Columns)"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow window up (Columns)"),

    # Floating toggle
    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating"),

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
    Group("5", label=" "),      
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
    layout.MonadTall(),
    layout.Bsp(),
    layout.Max(),
    layout.Columns(),
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
                       text=" 󰈸 ",
                       fontsize=30,
                       foreground="#3b82f6",  # Blue color to match your power menu
                       #mouse_callbacks={'Button1': lazy.spawn('/home/dev/.config/rofi/powermenu.sh')},
                       #padding=
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
                widget.Clock(format="  %Y-%m-%d %a    %I:%M %p"),
                widget.TextBox(
                       text=" ",
                       fontsize=18,
                       foreground="#3b82f6",  # Blue color to match your power menu
                       mouse_callbacks={'Button1': lazy.spawn('/home/dev/.config/rofi/powermenu.sh')},
                       padding=10
),
            ],
            28,
        ),
    ),
]

# --- Autostart hook ---
@hook.subscribe.startup_once
def start_apps():
    subprocess.Popen(["copyq"]) 
    subprocess.Popen(["flameshot"])
    subprocess.Popen([os.path.expanduser("~/.config/qtile/autostart.sh")])
