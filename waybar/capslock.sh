#!/bin/bash
## Check if capslock is pressed and return a status to waybar

for input in /sys/class/leds/*; do
    if [[ "$input" =~ .*capslock ]] && [[ $(cat "$input"/brightness) == "1" ]]; then
        echo '{"text": "locked", "alt": "locked", "class": "locked"}'
        exit 0
    fi
done

echo '{"text": "unlocked", "alt": "unlocked", "class": "unlocked"}'
