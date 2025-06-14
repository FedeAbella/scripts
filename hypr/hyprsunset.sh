#!/bin/bash
## Toggle hyprsunset on/off based on a config file

CONFIG_DIR="${HOME}"/.config/hyprsunset
CONFIG_FILE="${CONFIG_DIR}"/temp
DAY_TEMP="6000"
NIGHT_TEMP="3500"

current_temp=
if [[ ! -d "$CONFIG_DIR" ]]; then
    mkdir "$CONFIG_DIR"
fi

if [[ -f "$CONFIG_FILE" ]]; then
    current_temp=$(cat "$CONFIG_FILE")
else
    current_temp="$DAY_TEMP"
fi

if [[ "$current_temp" == "$DAY_TEMP" ]]; then
    hyprctl hyprsunset temperature "$NIGHT_TEMP"
    echo "$NIGHT_TEMP" >"$CONFIG_FILE"
else
    hyprctl hyprsunset identity
    echo "$DAY_TEMP" >"$CONFIG_FILE"
fi
