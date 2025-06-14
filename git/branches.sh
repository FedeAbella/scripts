#!/bin/bash
## Pretty list git branches with remote and description

print_string="\033[31;1mBranch\033[0m\t\033[31;1mRemote\033[0m\t\033[31;1mDescription\033[0m\n"

while read -r branch; do
    clean_branch_name=$(
        echo "${branch//\*\ /}" | # remove "* " marking current branch
            tr -d '[:cntrl:]' |
            sed -E "s/\[([0-9]{1,2}(;[0-9]{1,2})?)?[m|K]//g" | # remove colors
            sed -E "s/^.+ -> //g"                              # replace symbolic-ref like `HEAD -> master`
    )

    description=$(git config branch."$clean_branch_name".description)
    remote=$(git config branch."$clean_branch_name".remote)
    merge=$(git config branch."$clean_branch_name".merge | cut --delimiter="/" --fields=3-)

    branch_col="${branch}"
    if [[ "${branch::1}" != "*" ]]; then
        # Add spaces to account for "* " at the start of current branch
        branch_col="  ${branch_col}"
    fi

    remote_col=""
    if [[ -n "$remote" ]] && [[ -n "$merge" ]]; then
        remote_col="\e[1;34m[${remote}/${merge}]\e[0m"
    fi

    print_string="${print_string}${branch_col}\t${remote_col}\t${description}\n"
done <<<"$(git branch --list "--color")"

printf '%b' "$print_string" | column --table --separator $'\t'
