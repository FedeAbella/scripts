#!/bin/bash
## Check for updates to pacman and paru and notify waybar

pacman_packs="$(checkupdates | wc -l)"
aur_packs="$(paru -Qua | wc -l)"
total_packs=$((pacman_packs + aur_packs))
jq -c -M --arg num_pack "$total_packs" '.text = if ($num_pack | tonumber) > 0 then $num_pack else "" end | .class = if ($num_pack | tonumber) > 0 then "pending" else "ok" end | .alt = .class' < <(echo '{"text": "", "alt": "", "class": ""}')
