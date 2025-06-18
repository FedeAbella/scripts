#!/bin/bash
# Use rofi dmenu to change audio output device for a given app

sinks=$(pactl -f json list sinks 2>/dev/null | jq '.[] | "\(.properties."alsa.card_name") (\(.index))"' | sed -e 's/"//g')
apps=$(pactl -f json list sink-inputs | jq '.[] | "\(.properties."application.name") (\(.index))"' | sed -e 's/"//g')
{ [[ -n "$sinks" ]] && [[ -n "$apps" ]]; } || { notify-send "Failed to get audio info" && exit 1; }

chosen_app=$(echo "$apps" | rofi -dmenu -p "Choose app:" | sed -e 's/.*(\([0-9]\+\))/\1/')
[[ -n "$chosen_app" ]] || exit 0
chosen_sink=$(echo "$sinks" | rofi -dmenu -p "Choose output:" | sed -e 's/.*(\([0-9]\+\))/\1/')
[[ -n "$chosen_sink" ]] || exit 0

pactl move-sink-input "$chosen_app" "$chosen_sink"
