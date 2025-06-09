#!/bin/bash
## Check if usb drives are plugged in (and possibly mounted) and return info to waybar

json='{"text": "", "tooltip": "", "total": 0, "drives": []}'
for link in /dev/disk/by-id/*; do
    if [[ "$link" == "/dev/disk/by-id/usb-"* ]] && [[ "$link" == *"-part1" ]]; then
        drive="$(readlink -f "$link")"
        label="$(find -L /dev/disk/by-label -samefile "$drive" | cut -d "/" -f 5)"
        if [[ -z "$label" ]]; then
            label="no label"
        fi
        mountpoint=$(findmnt -nr -o target -S "$drive")
        if [[ -z "$mountpoint" ]]; then
            mountpoint="unmounted"
        fi
        json=$(jq -c -M --arg mountpoint "$mountpoint" --arg label "$label" --arg drive "$drive" '.drives += [$drive + " (" + $label + "): " + $mountpoint] | .total += 1' < <(echo "$json"))
    fi
done

jq -c -M '.text = if .total > 0 then (.total | tostring) else "" end | .tooltip = (.drives | join("\n"))' < <(echo "$json")
