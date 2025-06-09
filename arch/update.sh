#!/bin/bash
## Update all packages on a new kitty window, then refresh waybar module

kitty -e paru -Syu
pkill -SIGRTMIN+8 waybar
