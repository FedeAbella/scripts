#!/bin/bash
## Toggle hyprsunset on/off based on a config file

temp_dir="${HOME}"/.config/hyprsunset
temp_file="${temp_dir}"/temp
current_temp="6000"
night_temp="3500"

if [[ ! -d "$temp_dir" ]]; then
    mkdir "$temp_dir"
fi

if [[ -f "$temp_file" ]]; then
    current_temp=$(cat "$temp_file")
fi

if [[ "$current_temp" == "6000" ]]; then
    hyprctl hyprsunset temperature "$night_temp"
    echo "$night_temp" >"$temp_file"
else
    hyprctl hyprsunset identity
    echo "6000" >"$temp_file"
fi
