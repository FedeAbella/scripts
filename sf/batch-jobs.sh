#!/bin/bash

SRC_DIR=src
SUCCESS_FILE=all_success.csv
FAILED_FILE=all_failed.csv
ERRORS_FILE=all_errors
UNIQUE_ERRORS_FILE=unique_errors.csv
SUMMARY_FILE=summary

read -r -p "Enter target org: " target_org
read -r -p "Enter batch job IDs (space separated list): " -a ids

object=
job_num=0
total_processed=0
total_success=0
total_failed=0
total_unique=0
header=

if [[ ! -d "$SRC_DIR" ]]; then
    mkdir "$SRC_DIR"
fi
if [[ -f "$SUCCESS_FILE" ]]; then
    rm -f "$SUCCESS_FILE"
fi
if [[ -f "$FAILED_FILE" ]]; then
    rm -f "$FAILED_FILE"
fi
if [[ -f "$ERRORS_FILE" ]]; then
    rm -f "$ERRORS_FILE"
fi
if [[ -f "$UNIQUE_ERRORS_FILE" ]]; then
    rm -f "$UNIQUE_ERRORS_FILE"
fi

env printf "\n\e[1;34m-----\n\u279C Retrieving ${#ids[@]} jobs from $target_org\n-----\e[0m\n"
for id in "${ids[@]}"; do
    job_num=$((job_num + 1))
    echo "Retrieving job #$job_num, ID: $id..."

    job=$(sf data bulk results --target-org "${target_org}" --job-id "${id}" --json)

    if [[ -z "$job" ]]; then
        echo "sf cli returned no results. Skipping..." >&2
        continue
    fi

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

        if [[ ! -f "$SUCCESS_FILE" ]]; then
            echo "$success_header" >"$SUCCESS_FILE"
        fi

        tail -n +2 "$filename_success" >>"$SUCCESS_FILE"
        mv "$filename_success" "$SRC_DIR"/"$filename_success"
    fi

    if [[ -n $filename_failed ]]; then
        failed_header=$(head -n 1 "$filename_failed")

        if [[ "$header" != $(echo "$failed_header" | sed -e 's/"sf__[^"]\+",//g') ]]; then
            echo "Job columns don't match those of first job. Skipping..." >&2
            rm -f "$filename_failed"
            continue
        fi

        if [[ ! -f "$FAILED_FILE" ]]; then
            echo "$failed_header" >"$FAILED_FILE"
        fi

        tail -n +2 "$filename_failed" >>"$FAILED_FILE"
        mv "$filename_failed" "$SRC_DIR"/"$filename_failed"
    fi

    total_processed=$((total_processed + $(grep '"processedRecords":' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/')))
    total_success=$((total_success + $(grep '"successfulRecords":' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/')))
    total_failed=$((total_failed + $(grep '"failedRecords":' <(echo "$job") | sed -e 's/.*: \([0-9]\+\).*/\1/')))
done

if [[ -f "$FAILED_FILE" ]]; then
    env printf "\n\e[1;34m-----\n\u279C Extracting errors into $ERRORS_FILE and $UNIQUE_ERRORS_FILE...\n-----\e[0m\n"

    tail -n +2 "$FAILED_FILE" | sed 's|[^,]*,||' | sed 's|,.*||' >"$ERRORS_FILE"

    echo "count,error" >"$UNIQUE_ERRORS_FILE"
    sort "$ERRORS_FILE" | uniq -c | sort -n -r | sed 's| *||' | sed 's| |,|' >>"$UNIQUE_ERRORS_FILE"
    total_unique=$(tail -n +2 "$UNIQUE_ERRORS_FILE" | wc -l)
fi

cat >"$SUMMARY_FILE" <<EOL
Job ran at: $(date +"%F %T UTC%z")
Compiled jobs:
$(for jobId in "${ids[@]}"; do echo "$jobId"; done)

Total records: $total_processed
Successes: $total_success
Failures: $total_failed
Unique Errors: $total_unique

Successful results in "$SUCCESS_FILE"
EOL

if [[ $total_failed -gt 0 ]]; then
    cat >>"$SUMMARY_FILE" <<EOL
Failed results in "$FAILED_FILE"
All errors in "$ERRORS_FILE"
Unique errors in "$UNIQUE_ERRORS_FILE"
EOL
fi

env printf "\n\e[1;34m-----\n\u279C Results summary:\n-----\e[0m\n"
cat "$SUMMARY_FILE"
