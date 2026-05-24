#!/bin/bash

# 1. THE FIX: Define the desktop and sync D-Bus
# We set it to KDE so Dolphin/Brave know which portal logic to use
export XDG_CURRENT_DESKTOP=KDE
dbus-update-activation-environment --systemd DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP &

# 2. Background Services
#nitrogen --restore &
wal -R &
picom --experimental-backends &
nm-applet &
dunst &
flameshot &
copyq &
xset s 600 && xss-lock -- betterlockscreen -l &


# 3. Portals and Secrets
eval $(/usr/bin/gnome-keyring-daemon --start --components=secrets) &

# IMPORTANT: Instead of launching the libs directly, tell systemd to 
# refresh the portals with the new environment variables.
systemctl --user import-environment DISPLAY XAUTHORITY XDG_CURRENT_DESKTOP
systemctl --user restart xdg-desktop-portal
