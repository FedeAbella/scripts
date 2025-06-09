#!/bin/bash
# minimizes steam window to tray instead of killing if the window is closed
# https://wiki.hyprland.org/Configuring/Uncommon-tips--tricks/
if [ "$(hyprctl activewindow -j | jq -r ".class")" = "Steam" ]; then
    xdotool getactivewindow windowunmap
else
    hyprctl dispatch killactive ""
fi
