import os
import json

def get_colors():
    # Path to Pywal's generated colors
    cache_file = os.path.expanduser('~/.cache/wal/colors.json')
    
    if os.path.isfile(cache_file):
        with open(cache_file) as f:
            data = json.load(f)
            return {
                "bg": data['special']['background'],
                "fg": data['special']['foreground'],
                "acc": data['colors']['color1'],  # Primary Accent
                "sec": data['colors']['color2'],  # Secondary Accent
                "err": data['colors']['color3'],  # Error/Warning
                "pal": data['colors']             # Full Palette
            }
    else:
        # High-end default (Dracula-style) fallback
        return {"bg": "#282a36", "fg": "#f8f8f2", "acc": "#bd93f9", "sec": "#ff79c6", "err": "#ff5555"}

colors = get_colors()
