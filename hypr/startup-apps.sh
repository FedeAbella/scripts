#!/bin/bash
## Run startup apps silently on different workspaces for personal/work profiles

user=$(whoami)

case $user in
    fede)
        hyprctl dispatch exec "[workspace 4] kitty -e btop"
        hyprctl dispatch exec "[workspace 7 silent] flatpak run com.rtosta.zapzap"
        hyprctl dispatch exec "[workspace 7 silent] discord"
        steam -silent &
        sleep 3
        hyprctl dispatch exec "[workspace 1] firefox"
        ;;
    attentis)
        hyprctl dispatch exec "[workspace 7 silent] teams-for-linux --enable-features=UseOzonePlatform --ozone-platform=wayland"
        hyprctl dispatch exec "[workspace 4 silent] chromium --profile-directory='Profile 1'"
        hyprctl dispatch exec "[workspace 2 silent] kitty"
        hyprctl dispatch exec "[workspace 9 silent] firefox"
        hyprctl dispatch exec "[workspace 7 silent] flatpak run com.rtosta.zapzap"
        sleep 3
        hyprctl dispatch exec "[workspace 1] chromium --profile-directory='Default'"
        ;;
    *) ;;
esac
