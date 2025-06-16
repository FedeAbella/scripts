#!/bin/bash
# Toggle dpms on auxiliary monitors to focus on main (game, movie, etc)

auxiliary=("HDMI-A-1" "DP-1")

for monitor in "${auxiliary[@]}"; do
    hyprctl dispatch dpms toggle "$monitor"
done
