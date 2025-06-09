#!/bin/bash
## Check if dotfiles repo is stale and return text to waybar

git -C "{$HOME}"/.dotfiles fetch &>/dev/null
behind=$(git -C "{$HOME}"/.dotfiles rev-list --count main..origin/main)
ahead=$(git -C "{$HOME}"/.dotfiles rev-list --count origin/main..main)

text=""
if [[ "$behind" -gt 0 ]]; then
    text=" $behind"
fi
if [[ "$behind" -gt 0 ]] && [[ "$ahead" -gt 0 ]]; then
    text="$text "
fi
if [[ "$ahead" -gt 0 ]]; then
    text="$text $ahead"
fi

if [[ -n "$text" ]]; then
    text=" $text"
fi

echo "$text"
