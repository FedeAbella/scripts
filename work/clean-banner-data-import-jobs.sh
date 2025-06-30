#!/bin/bash

if [[ -z "$1" ]]; then
    echo "file name required" >&2
    exit 1
fi

nvim --headless -c '%s/, /T/g' -c '%norm f	cf	,f cf	,f c4f	,f	s,f	s,f	d$' -c 'g/^/m0' -c 'norm ggOjob,started,ended,object,processed,failed' -c 'wq' "$1"
nvim "$1"
