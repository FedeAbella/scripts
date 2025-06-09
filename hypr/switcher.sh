#!/usr/bin/env sh
## Switch users on hyprland

qdbus --system org.freedesktop.DisplayManager /org/freedesktop/DisplayManager/Seat0 org.freedesktop.DisplayManager.Seat.SwitchToGreeter
