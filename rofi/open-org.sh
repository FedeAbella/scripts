#!/bin/bash

declare -A types=(
    ["Other"]="#cba6f7"
    ["Sandbox"]="#f9e2af"
    ["DevHub"]="#a6e3a1"
    ["Scratch"]="#cdd6f4"
)

format() {
    read -r org
    for type in "${!types[@]}"; do
        org=$(sed "s|\"\/${type}\/|<span color='${types["$type"]}'> ($type) |" <(echo "$org"))
    done
    org=$(sed 's|"|</span>|' <(echo "$org"))
    echo "$org"
}

command -v sf >/dev/null || exit 1

orgs=$(sf org list --skip-connection-status --json)
[ $? ] || exit 1

[ "$(grep '"status": [0-9]' <(echo "$orgs") | sed 's/.*: \([0-9]\)\+.*/\1/')" ] || exit 1

chosen=$(jq '[.result.nonScratchOrgs.[] | {username, alias, isDevHub: .isDevHub // false, isSandbox: .isSandbox // false, isScratch: false}] + [.result.scratchOrgs.[] | {username, alias, isDevHub, isSandbox, isScratch}] | .[] | "/\(if .isScratch then "Scratch" elif .isDevHub then "DevHub" elif .isSandbox then "Sandbox" else "Other" end)/\(.alias)"' \
    <(echo "$orgs") |
    format |
    sort |
    rofi -dmenu -markup-rows -p "  Orgs" -format p | sed 's/(.*) //')

[ -n "$chosen" ] || exit 1

sf org open -o "$chosen"
