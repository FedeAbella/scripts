#!/bin/bash

git_root=$(git rev-parse --show-toplevel 2>&1)
[[ -d "$git_root" ]] || { echo "Not a git repository" >&2 && return 1; }

. "$HOME/scripts/git/prettylog.sh" | fzf --ansi --no-sort --reverse --preview="git show --color=always {1}" | sed -e "s/ .*//"
