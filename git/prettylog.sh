#!/bin/bash

git_root=$(git rev-parse --show-toplevel 2>&1)
[[ -d "$git_root" ]] || { echo "Not a git repository" >&2 && return 1; }

git log --color=always --pretty="%C(red)%h%C(auto)%d%Creset %s %C(yellow)by %an %C(cyan)(%ar)%Creset"
