#!/bin/bash
# Use rofi dmenu to change the default audio output device

sinks=$(pactl -f json list sinks 2>/dev/null | jq '[.[] | {name: .properties."alsa.card_name", id: .index}]')

chosen_sink=$(jq '.[] | .name' <(echo "$sinks") | sed -e 's/\(^"\)\|\("$\)//g' | rofi -dmenu -p "Choose output:" -format i)
[[ -n "$chosen_sink" ]] || exit 0

pactl set-default-sink "$(jq --argjson ind "$chosen_sink" '.[$ind] | .id' <(echo "$sinks"))"
notify-send "Switched audio to $(jq --argjson ind "$chosen_sink" '.[$ind] | .name' <(echo "$sinks"))"
