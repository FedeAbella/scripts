#!/bin/bash
## Pull another branch and rebase current branch from that one

remote=origin

[[ -n "$1" ]] || { echo "Must specify branch to rebase from" >&2 && exit 1; }

[[ -n $2 ]] && remote=$2

git pull "$remote" "$1:$1" && git rebase "$1"
