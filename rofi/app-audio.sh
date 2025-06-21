#!/bin/bash
# Use rofi dmenu to change audio output device for a given app

sinks=$(pactl -f json list sinks 2>/dev/null | jq '[.[] | {name: .properties."alsa.card_name", id: .index}]')
apps=$(pactl -f json list sink-inputs | jq '[.[] | {name: .properties."application.name", id: .index, media: .properties."media.name"}]')

chosen_app=$(jq '.[] | "\(.name)    --    \(.media)"' <(echo "$apps") | sed -e 's/\(^"\)\|\("$\)//g' | rofi -theme-str "*{ width: 1000;}" -dmenu -p "Choose app:" -format i)
[[ -n "$chosen_app" ]] || exit 0
chosen_sink=$(jq '.[] | .name' <(echo "$sinks") | sed -e 's/\(^"\)\|\("$\)//g' | rofi -dmenu -p "Choose output:" -format i)
[[ -n "$chosen_sink" ]] || exit 0

pactl move-sink-input "$(echo "$apps" | jq --argjson ind "$chosen_app" '.[$ind] | .id')" "$(echo "$sinks" | jq --argjson ind "$chosen_sink" '.[$ind] | .id')"
