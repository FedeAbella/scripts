#!/bin/bash
## Create a local .gitignore file

git_root=$(git rev-parse --show-toplevel 2>&1)
[[ -d "$git_root" ]] || { echo "Not a git repository" >&2 && exit 1; }

ln -sf "$git_root"/.git/info/exclude "$git_root"/.gitignore-local
echo ".gitignore-local" >>"$git_root"/.gitignore-local
