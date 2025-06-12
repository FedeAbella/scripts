#!/bin/bash

read -r -p "Enter target org: " target_org
read -r -p "Enter batch job IDs (space separated list): " -a ids

object=
job_num=0
total_processed=0
total_success=0
total_failed=0
total_unique=0
header=

if [[ ! -d src ]]; then
    mkdir src
fi
if [[ -f all_success.csv ]]; then
    rm -f all_success.csv
fi
if [[ -f all_failed.csv ]]; then
    rm -f all_failed.csv
fi
if [[ -f all_errors.csv ]]; then
    rm -f all_errors.csv
fi
if [[ -f unique_errors.csv ]]; then
    rm -f unique_errors.csv
fi

env printf "\n\e[1;34m-----\n\u279C Retrieving ${#ids[@]} jobs from $target_org\n-----\e[0m\n"
for id in "${ids[@]}"; do
    job_num=$((job_num + 1))
    echo "Retrieving job #$job_num, ID: $id..."

    job=$(sf data bulk results --target-org "${target_org}" --job-id "${id}" --json)

    if [[ $(grep '"status": [0-9]' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/') != "0" ]]; then
        echo "Job query failed with error \"$(grep '"message":' <(echo "$job") | sed -e 's/.*: "\(.*\)".*/\1/')\"" >&2
        echo "Skipping..." >&2
        continue
    fi

    if [[ ! $(grep '"status": "' <(echo "$job") | sed -e 's/.*: "\(.*\)".*/\1/') =~ ^JobComplete$ ]]; then
        echo "Job $id did not complete successfully. Skipping..." >&2
        continue
    fi

    filename_success=$(grep '"successFilePath"' <(echo "$job") | sed -e 's/.*: "\(.*\)".*/\1/')
    filename_failed=$(grep '"failedFilePath"' <(echo "$job") | sed -e 's/.*: "\(.*\)".*/\1/')

    job_object=$(grep '"object"' <(echo "$job") | sed -e 's/.*: "\(.*\)".*/\1/')
    if [[ -z $object ]]; then
        object=$job_object
        echo "sObject set to $object"
    elif [[ "$object" != "$job_object" ]]; then
        echo "Job sObject $job_object does not match previously found sObject $object. Skipping..." >&2
        if [[ -f "$filename_success" ]]; then
            rm -f "$filename_success"
        fi
        if [[ -f "$filename_failed" ]]; then
            rm -f "$filename_failed"
        fi
        continue
    fi

    if [[ -z $header ]]; then
        if [[ -n $filename_success ]]; then
            header=$(head -n 1 "$filename_success" | sed -e 's/"sf__[^"]\+",//g')
        else
            header=$(head -n 1 "$filename_failed" | sed -e 's/"sf__[^"]\+",//g')
        fi
    fi

    if [[ -n $filename_success ]]; then
        success_header=$(head -n 1 "$filename_success")

        if [[ "$header" != $(echo "$success_header" | sed -e 's/"sf__[^"]\+",//g') ]]; then
            echo "Job columns don't match those of first job. Skipping..." >&2
            rm -f "$filename_success"
            continue
        fi

        if [[ ! -f all_success.csv ]]; then
            echo "$success_header" >all_success.csv
        fi

        tail -n +2 "$filename_success" >>all_success.csv
        mv "$filename_success" src/"$filename_success"
    fi

    if [[ -n $filename_failed ]]; then
        failed_header=$(head -n 1 "$filename_failed")

        if [[ "$header" != $(echo "$failed_header" | sed -e 's/"sf__[^"]\+",//g') ]]; then
            echo "Job columns don't match those of first job. Skipping..." >&2
            rm -f "$filename_failed"
            continue
        fi

        if [[ ! -f all_failed.csv ]]; then
            echo "$failed_header" >all_failed.csv
        fi

        tail -n +2 "$filename_failed" >>all_failed.csv
        mv "$filename_failed" src/"$filename_failed"
    fi

    total_processed=$((total_processed + $(grep '"processedRecords":' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/')))
    total_success=$((total_success + $(grep '"successfulRecords":' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/')))
    total_failed=$((total_failed + $(grep '"failedRecords":' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/')))
done

if [[ -f all_failed.csv ]]; then
    env printf "\n\e[1;34m-----\n\u279C Extracting errors into all_errors and unique_errors.csv...\n-----\e[0m\n"

    tail -n +2 all_failed.csv | sed 's|[^,]*,||' | sed 's|,.*||' >all_errors

    echo "count,error" >unique_errors.csv
    sort all_errors | uniq -c | sort -n -r | sed 's| *||' | sed 's| |,|' >>unique_errors.csv
    total_unique=$(tail -n +2 unique_errors.csv | wc -l)
fi

cat >summary <<EOL
Job ran at: $(date +"%F %T UTC%z")
Compiled jobs:
$(for jobId in "${ids[@]}"; do echo "$jobId"; done)

Total records: $total_processed
Successes: $total_success
Failures: $total_failed
Unique Errors: $total_unique

Successful results in all_success.csv
EOL

if [[ $total_failed -gt 0 ]]; then
    cat >>summary <<EOL
Failed results in all_failed.csv
All errors in all_errors
Unique errors in unique_errors.csv
EOL
fi

env printf "\n\e[1;34m-----\n\u279C Results summary:\n-----\e[0m\n"
cat summary
