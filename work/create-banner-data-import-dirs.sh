#!/bin/bash

today=$(date +"%F" | sed -e 's/-//g')
mkdir -p "$today"/organizations \
    "$today"/org_contacts \
    "$today"/taxonomies \
    "$today"/specialties \
    "$today"/products \
    "$today"/practitioners/account \
    "$today"/practitioners/provider \
    "$today"/locations/account \
    "$today"/locations/facility \
    "$today"/locations/provider \
    "$today"/languages \
    "$today"/hps \
    "$today"/hpt \
    "$today"/hpf \
    "$today"/hfn \
    "$today"/cpfs

cd "$today" || exit
