#!/bin/bash
## Move to previous hyprland workspace in monitor, cycling if on first
## Uses current 3 monitor config with 3 workspaces per monitor

workspace=$(hyprctl activeworkspace | head -n 1 | grep -o -P '(?<=workspace ID )\d+')

if [ "$workspace" == "1" ] || [ "$workspace" == "4" ] || [ "$workspace" == "7" ]; then
    hyprctl dispatch movetoworkspace m~3
    exit 0
fi

hyprctl dispatch movetoworkspace r-1
