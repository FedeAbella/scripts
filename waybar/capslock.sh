#!/bin/bash
## Check if capslock is pressed and return a status to waybar

capslock=$(cat /sys/class/leds/input10::capslock/brightness)

if [[ "$capslock" == "1" ]]; then
    echo '{"text": "locked", "alt": "locked", "class": "locked"}'
    exit 0
fi

echo '{"text": "unlocked", "alt": "unlocked", "class": "unlocked"}'
