#!/bin/bash
## Check if microphone, camera and/or screensharing are in use and return info to waybar

icons='{"Audio": "  ", "Video": " 󱒃 ", "Webcam": " 󰖠 "}'

categories=$(pw-dump | jq '[.[].info | select(has("state")) | select(.state == "running") | .props | select(."media.class" | contains("Stream/Input")) | {"class": ."media.class" | split("/") | last, "app": (."application.process.binary" // ."node.name")}] | group_by(.class) | map({class:.[0].class, apps:map(.app)}) | . + [{"class": "Webcam", "apps": []}]')

while read -r device; do
    if fuser "$device" &>/dev/null; then
        pid=$(fuser "$device" 2>/dev/null | head -n 1 | sed 's/\s*//')
        app=$(ps -p "$pid" -o comm=)
        if [[ $app == *"wireplumber"* ]]; then
            continue
        fi
        categories=$(jq --arg app "$app" 'map(select(.class == "Webcam").apps += [$app])' < <(echo "$categories"))
    fi
done < <(ls /dev/video*)

output=$(jq --argjson icons "$icons" 'reduce ([.[] | select(.apps | length > 0)] | sort_by(.class) | reverse | .[]) as $x ([]; . + [$icons[$x.class]]) | join("")' < <(echo "$categories"))
echo "{\"text\": $output}"
