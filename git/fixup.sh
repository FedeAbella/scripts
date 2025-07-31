#!/bin/bash

git_root=$(git rev-parse --show-toplevel 2>&1)
[[ -d "$git_root" ]] || { echo "Not a git repository" >&2 && return 1; }

git commit --fixup "$(. "$HOME/scripts/git/gethash.sh")"
