#!/bin/bash

subdirs=(
    "organizations"
    "contacts"
    "taxonomies"
    "specialties"
    "products"
    "practitioners/account"
    "practitioners/provider"
    "locations/account"
    "locations/facility"
    "locations/provider"
    "languages"
    "hps"
    "hpt"
    "hpf"
    "hfn"
    "cpfs"
    "claims"
)

today=$(date +"%F" | sed -e 's/-//g')
for subdir in "${subdirs[@]}"; do
    mkdir -p "$today"/"$subdir"
done

cd "$today" || exit
