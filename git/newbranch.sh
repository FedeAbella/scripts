#!/bin/bash
## Create a new git branch from another, move to it and add a description

if [[ -z $1 ]] || [[ -z $2 ]]; then
    echo "Must specify to and from branches" >&2
    exit 1
fi

git switch "$1" && git pull && git switch -c "$2" && git branch --edit-description
