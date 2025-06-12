#!/bin/bash

if [[ ! -d "$HOME"/.config/sf-orgs ]]; then
    mkdir "$HOME"/.config/sf-orgs
fi

orgs=$(sf org list --skip-connection-status --json)
if [[ ! $? ]]; then
    exit 1
fi

if [[ ! $(grep '"status": [0-9]' <(echo "$orgs") | sed 's/.*: \([0-9]\)\+.*/\1/') ]]; then
    exit 1
fi

logins=$(jq '[.result.nonScratchOrgs.[] | {username, alias, isDevHub: .isDevHub // false, isSandbox: .isSandbox // false, isScratch: false}] + [.result.scratchOrgs.[] | {username, alias, isDevHub, isSandbox, isScratch}]' <(echo "$orgs"))

chosen=$(jq '.[].alias' <(echo "$logins") | sed 's/"/<b>/' | sed 's/"/<\/b>/' | sort | rofi -dmenu -markup-rows -p "  Orgs" -format p)
if [[ -z "$chosen" ]]; then
    exit 1
fi
sf org open -o "$chosen"
