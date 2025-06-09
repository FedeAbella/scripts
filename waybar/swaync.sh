#!/bin/bash
## Check if swaync has notifications or if it's inhibited and return info to waybar

jq -c -M --argjson inhibited "$(swaync-client -I)" --argjson dnd "$(swaync-client -D)" --argjson num "$(swaync-client -c)" '.class = if ($inhibited or $dnd) then "inhibited" elif $num > 0 then "unread" else "read" end | .alt = .class' < <(echo '{"text": ""}')
