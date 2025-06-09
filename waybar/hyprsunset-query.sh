#!/bin/bash
## Query a config file for hyprsunset to check if it's enabled and notify waybar

current_temp="6000"

if [[ -d ${HOME}/.config/hyprsunset ]] && [[ -f ${HOME}/.config/hyprsunset/temp ]]; then
    current_temp=$(cat "${HOME}"/.config/hyprsunset/temp)
fi

if [[ "$current_temp" == "6000" ]]; then
    echo '{"alt": "disabled", "class": "disabled"}'
else
    echo '{"alt": "enabled", "class": "enabled"}'
fi
