#!/bin/bash

git_root=$(git rev-parse --show-toplevel 2>&1)
[[ -d "$git_root" ]] || { echo "Not a git repository" >&2 && return 1; }

hash=$(. "$HOME/scripts/git/gethash.sh")
print -z "git rebase -i $hash"
