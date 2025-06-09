#!/bin/bash
## Switch to another branch and pull to it

[[ -n "$1" ]] || { echo "Must specify branch to switch to" >&2 && exit 1; }

git switch "$1" && git pull
