#!/bin/bash

declare -A TYPES=(
    ["Other"]="#cba6f7"
    ["Sandbox"]="#fab387"
    ["DevHub"]="#a6e3a1"
    ["Scratch"]="#f5e0dc"
)

format() {
    while read -r org; do
        org=$(sed 's|"||' <(echo "$org"))
        for type in "${!TYPES[@]}"; do
            org=$(sed "s|/${type}/\"|<span color='${TYPES["$type"]}'> ($type)</span>|" <(echo "$org"))
        done
        echo "$org"
    done
}

notify-send "Querying orgs..." --urgency low --expire-time 1000 --transient

# Need to load nvm otherwise sf is not available when launching through keybind
# shellcheck disable=SC1091
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

command -v sf >/dev/null || { notify-send "sf command not found" && exit 1; }

orgs=$(sf org list --skip-connection-status --json)
[ $? ] || { notify-send "sf cli command failed" && exit 1; }

[ "$(grep '"status": [0-9]' <(echo "$orgs") | sed 's/.*: \([0-9]\)\+.*/\1/')" ] || { notify-send "Failed to get orgs from cli command" && exit 1; }

chosen=$(jq '[.result.nonScratchOrgs.[] | {username, alias, isDevHub: .isDevHub // false, isSandbox: .isSandbox // false, isScratch: false}] + [.result.scratchOrgs.[] | {username, alias, isDevHub, isSandbox, isScratch}] | .[] | "\(.alias)/\(if .isScratch then "Scratch" elif .isDevHub then "DevHub" elif .isSandbox then "Sandbox" else "Other" end)/"' \
    <(echo "$orgs") |
    format |
    sort |
    rofi -dmenu -markup-rows -p "  Orgs" -format p | sed 's/ (.*)//')

[ -n "$chosen" ] || exit 1

sf org open -o "$chosen"
