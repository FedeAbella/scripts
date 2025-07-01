#!/bin/bash

target_org=$1
if [[ -z "$target_org" ]]; then
    echo "target org is required" >&2
    exit 1
fi

while read -r file; do
    dir="$(dirname "$file")"
    (
        cd "$dir" || return
        job_ids=()
        while read -r job; do
            job_ids+=("$job")
        done < <(tail -n +2 jobs.csv | cut -d ',' -f 1)
        bash "$HOME"/scripts/sf/batch-jobs.sh "$target_org" "${job_ids[@]}"
    )
done < <(find . -wholename './*/jobs.csv')
