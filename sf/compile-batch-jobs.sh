#!/bin/bash

read -r -p "Enter target org: " target_org
read -r -p "Enter batch job IDs (space separated list): " -a ids

for id in "${ids[@]}"; do
    env printf "\n\e[1;34m-----\n\u279C Retrieving job ${id}\n-----\e[0m\n"
    sf data bulk results --target-org "${target_org}" --job-id "${id}"
done

env printf "\n\e[1;34m-----\n\u279C Compiling results into all_success.csv and all_failed.csv\n-----\e[0m\n"
if [[ -f all_success.csv ]]; then
    rm -f all_success.csv
fi
if [[ -f all_failed.csv ]]; then
    rm -f all_failed.csv
fi
if [[ ! -d src/ ]]; then
    mkdir src/
fi

first_success=true
first_failed=true
for id in "${ids[@]}"; do
    filename_success="${id}-success-records.csv"
    filename_failed="${id}-failed-records.csv"

    if [[ -f "${filename_success}" ]]; then
        if [[ ${first_success} = true ]]; then
            head -n 1 "${filename_success}" >all_success.csv
            first_success=false
        fi
        tail -n +2 "${filename_success}" >>all_success.csv
        mv "${filename_success}" src/"${filename_success}"
    fi

    if [[ -f "${filename_failed}" ]]; then
        if [[ "${first_failed}" = true ]]; then
            head -n 1 "${filename_failed}" >all_failed.csv
            first_failed=false
        fi
        tail -n +2 "$filename_failed" >>all_failed.csv
        mv "${filename_failed}" src/"${filename_failed}"
    fi
done

if [[ -f all_failed.csv ]]; then
    env printf "\n\e[1;34m-----\n\u279C Extracting all errors into all_errors and unique_errors.csv...\n-----\e[0m\n"
    if [[ -f all_errors ]]; then
        rm -f all_errors
    fi
    if [[ -f unique_errors.csv ]]; then
        rm -f unique_errors.csv
    fi
    tail -n +2 all_failed.csv | sed 's|[^,]*,||' | sed 's|,.*||' >all_errors
    echo "count,error" >unique_errors.csv
    sort all_errors | uniq -c | sort -n -r | sed 's| *||' | sed 's| |,|' >>unique_errors.csv
fi

total_success=0
total_failures=0
total_unique=0
if [[ -f all_success.csv ]]; then
    total_success=$(tail -n +2 all_success.csv | wc -l)
fi
if [[ -f all_failed.csv ]]; then
    total_failures=$(tail -n +2 all_failed.csv | wc -l)
    total_unique=$(tail -n +2 unique_errors.csv | wc -l)
fi

total_records=$((total_success + total_failures))

cat >summary <<EOL
Job ran at: $(date +"%F %T UTC%z")
Compiled jobs:
$(for jobId in "${ids[@]}"; do echo "$jobId"; done)

Total records: $total_records
Successes: $total_success
Failures: $total_failures
Unique Errors: $total_unique

Successful results in all_success.csv
Failed results in all_failed.csv
Unique errors in unique_errors.csv
EOL

env printf "\n\e[1;34m-----\n\u279C Results summary:\n-----\e[0m\n"
cat summary
