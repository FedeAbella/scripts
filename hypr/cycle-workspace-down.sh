#!/bin/bash
## Cycle hyprland workspaces down per monitor
## Uses current 3 monitor config with 3 workspaces per monitor

workspace=$(hyprctl activeworkspace | head -n 1 | grep -o -P '(?<=workspace ID )\d+')

if [ "$workspace" == "1" ] || [ "$workspace" == "4" ] || [ "$workspace" == "7" ]; then
    hyprctl dispatch workspace m~3
    exit 0
fi

hyprctl dispatch workspace r-1
