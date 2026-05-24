from libqtile import bar, layout, widget, hook, qtile
from libqtile.config import Key, Group, Screen, Match, ScratchPad, DropDown
from libqtile.lazy import lazy
from qtile_extras.popup import PopupRelativeLayout, PopupWidget
from qtile_extras import widget as ext_widget
from qtile_extras.widget.decorations import RectDecoration
from theme_gen import colors
import subprocess
import os

mod = "mod4"  # Super/Windows key
terminal = "alacritty"

# --- Keybindings ---
keys = [
    Key([mod], "Return", lazy.spawn(terminal), desc="Launch terminal"),
    Key([mod], "s", lazy.spawn("rofi -show drun -modi 'drun,run,filebrowser,settings:~/.config/rofi/settings/settings-mode.sh' -sidebar-mode -theme ~/.config/rofi/themes/tokyo-night.rasi")),
    Key([mod], "q", lazy.window.kill(), desc="Close window"),
    Key([mod], "b", lazy.spawn("vivaldi"), desc="Open browser"),
    Key([mod], "e", lazy.spawn("dolphin"), desc="Open Dolphin"),
    Key([], "Print", lazy.spawn("flameshot gui"), desc="Screenshot"),
    Key([mod, "shift"], "Print", lazy.spawn("flameshot full -c"), desc="Screenshot to clipboard"),

    Key([mod], "Tab", lazy.next_layout(), desc="Cycle layouts"),

    Key([mod], "h", lazy.layout.left(), desc="Focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "j", lazy.layout.down(), desc="Focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus up"),

    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),

    Key([mod, "control"], "h", lazy.layout.shrink(), desc="Shrink"),
    Key([mod, "control"], "l", lazy.layout.grow(), desc="Grow"),
    Key([mod, "control"], "j", lazy.layout.grow_down(), desc="Grow down"),
    Key([mod, "control"], "k", lazy.layout.grow_up(), desc="Grow up"),

    Key([mod], "t", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Toggle fullscreen"),

    Key([mod, "control"], "r", lazy.restart(), desc="Restart Qtile"),
    Key([mod, "control"], "q", lazy.spawn(os.path.expanduser("~/.config/rofi/powermenu.sh"))),
]

# --- Groups ---
groups = [
    Group("1", label=""),
    Group("2", label=""),
    Group("3", label=""),
    Group("4", label=""),
    Group("5", label=""),
]

for i in groups:
    keys.extend([
        Key([mod], i.name, lazy.group[i.name].toscreen(), desc=f"Switch to group {i.name}"),
        Key([mod, "shift"], i.name, lazy.window.togroup(i.name), desc=f"Move window to group {i.name}"),
    ])

# Add the ScratchPad group
groups.append(
    ScratchPad("scratchpad", [
        DropDown(
            "control_center", 
            os.path.expanduser("~/.config/qtile/control_center.py"),
            x=0.8477, y=0.0038, width=0.15, height=0.4,
            on_focus_lost_hide=True,
            focus_delay=1.0,
            opacity=0.95,
            warp_pointer=True,
        ),
    ])
)

# --- Layouts ---
layouts = [
    layout.MonadTall(margin=3, border_width=1, border_focus=colors['acc']),
    layout.Columns(margin=3, border_width=1, border_focus=colors['acc']),
    layout.Max(margin=3),
    layout.Bsp(margin=3, border_width=1, border_focus=colors['acc']),
    layout.Stack(margin=3, border_width=1),
]

floating_layout = layout.Floating(
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(title="Confirmation"),
        Match(title="Error"),
        Match(title="File Operation Progress"),
        Match(wm_class="ssh-askpass"),
        Match(wm_class="qalculate-gtk"),
        Match(wm_class="gnome-calendar"),
        Match(wm_class="pinentry")
    ]
)

# --- Decoration helper ---
def get_decoration(color_start, color_end=None):
    """
    Returns a RectDecoration with either a solid color or a gradient.
    - If only color_start is provided, you get a solid background.
    - If both color_start and color_end are provided, you get a horizontal gradient.
    """
    if color_end is None:
        colour = color_start
    else:
        colour = [color_start, color_end]

    return [
        RectDecoration(
            colour=colour,
            radius=0,     # square corners
            filled=True,
            padding_y=4,
            group=True,
        )
    ]

def open_weather_channel(): 
        subprocess.Popen([ 
            "xdg-open", "https://weather.com/weather/today/l/36d823c0db9f4e270803684b94e74f3765f178c5d9f33fcff5b26add28a4a22c" 
            ])

# --- Widgets / Screens ---
widget_defaults = dict(font="Ubuntu", fontsize=14, padding=3)

screens = [
    Screen(
        top=bar.Bar(
            [
                ext_widget.TextBox(
                    text="  ",
                    fontsize=18,
                    foreground=colors['acc'],
                    mouse_callbacks={'Button1': lazy.spawn(
                        'rofi -show drun -modi drun,run,filebrowser,ssh -sidebar-mode -theme ~/.config/rofi/themes/tokyo-night.rasi'
                    )},
                    padding=5,
                ),

                ext_widget.Spacer(length=10),

                ext_widget.CurrentLayoutIcon(
                    custom_icon_paths=[os.path.expanduser("~/.config/qtile/icons")],
                    scale=0.7,
                    padding=0,
                    foreground=colors['fg'],
                ),
                ext_widget.WindowName(
                    foreground=colors['fg'],
                    format='{name}',
                    max_chars=30,
                ),

                widget.Spacer(),

                ext_widget.GroupBox(
                    highlight_method='text',
                    use_label=True,
                    font="JetBrainsMono Nerd Font",
                    fontsize=18,
                    hide_unused=True,
                    active=colors['fg'],
                    inactive=colors['pal'].get('color8', '#888888'),
                    this_current_screen_border=colors['acc'],
                    other_current_screen_border=colors['sec'],
                ),

                #ext_widget.Spacer(length=10),

                widget.Spacer(),

                # --- Climate Widget (scroll to toggle views) ---
                widget.OpenWeather( 
                    app_key="843426c48705bf9498a000dc71ccfc4d", 
                    cityid="3492908", # e.g., 5128581 for New York 
                    update_interval=600,
                    format="{icon} {weather} {main_temp}°C",
                    metric=True, 
                    mouse_callbacks={"Button1": open_weather_channel}
                    ),

                ext_widget.Spacer(length=100),

                ext_widget.TextBox(
                    text="󰭵 ",
                    mouse_callbacks={'Button1': lambda: qtile.groups_map["scratchpad"].dropdown_toggle("control_center")},
                    fontsize=20,                   
                    foreground=colors['fg'],
                ),

                ext_widget.Clock(
                    format=" %I:%M | %m/%d/%y ",
                    fontsize=14,
                    foreground=colors['fg'],
                ),

                  ext_widget.TextBox(
                    text="󰂞 ",
                    fontsize=15,
                    foreground=colors['fg'],
                    #mouse_callbacks={'Button1': lazy.function(show_system_dashboard)},
                ),
            ],
            36,
            background=colors['bg'] + "CC",  # semi-transparent bar background
            margin=[0, 0, 0, 0],             # full width, corner-to-corner
        ),
    ),
]

# --- Autostart hook ---
@hook.subscribe.startup_once
def start_apps():
    subprocess.Popen([os.path.expanduser("~/.config/qtile/autostart.sh")])
    polkit_agent = "/usr/lib/polkit-kde-authentication-agent-1"
    if os.path.exists(polkit_agent):
        subprocess.Popen([polkit_agent])
