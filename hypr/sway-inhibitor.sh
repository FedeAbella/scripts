#!/usr/bin/env bash

SOCKET="$XDG_RUNTIME_DIR"/hypr/"$HYPRLAND_INSTANCE_SIGNATURE"/.socket2.sock

handle() {
    case $1 in
        screencast*)
            if [[ "${1:12:1}" -eq 1 ]]; then
                notify-send -e -t 2000 "Sharing screen. Inhibiting swaync"
                swaync-client --inhibitor-add "screencast"
            else
                swaync-client --inhibitor-remove "screencast"
                notify-send -e -t 2000 "Stopped sharing screen. Clearing swaync"
            fi
            ;;
    esac
}

socat -U - UNIX-CONNECT:"$SOCKET" | while read -r line; do handle "$line"; done
