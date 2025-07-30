#!/bin/bash
## Take a screenshot with hyprshot and annotate with satty

filename=$(hyprcap shot region --freeze --no-notify -F 2>/dev/null | sed -e 's/[^\/]*\(\/\)/\1/')
output_filename=$(date +'%F-%H%M%S_annotated.png')
wait_deadline=$((SECONDS + 5))
if [[ -n "$filename" ]]; then
    while [[ ! -f "$filename" ]] && [[ $SECONDS -lt $wait_deadline ]]; do
        :
    done
    satty --filename "$filename" --output-filename "$HOME/Pictures/Screenshots/$output_filename"
else
    notify-send -e "hyprcap failed"
fi
