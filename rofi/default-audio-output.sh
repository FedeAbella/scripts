#!/bin/bash
# Use rofi dmenu to change the default audio output device

sinks=$(pactl -f json list sinks 2>/dev/null | jq '.[] | "\(.properties."alsa.card_name") (\(.index))"' | sed -e 's/"//g')
{ [[ -n "$sinks" ]]; } || { notify-send "Failed to get audio info" && exit 1; }

chosen_sink=$(echo "$sinks" | rofi -dmenu -p "Choose output:" | sed -e 's/.*(\([0-9]\+\))/\1/')
[[ -n "$chosen_sink" ]] || exit 0

pactl set-default-sink "$chosen_sink"
notify-send "Switched audio to $(grep "$chosen_sink" <(echo "$sinks") | sed -e 's/ (.*//')"
