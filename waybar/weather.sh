#!/bin/bash
## Check wttr.in for local weather and notify waybar

location="Montevideo+Uruguay"

for i in {1..5}; do
    if weather="$(curl -s https://wttr.in/$location?format=%c+%t+%p+%w | sed 's/\s\+/ /g' | sed 's/+//g')"; then
        jq -c -M --arg weather "$weather" '.icon = ($weather | split(" ") | .[0]) | .temp = "🌡️" + ($weather | split(" ") | .[1]) | .prec = "☔" + ($weather | split(" ") | .[2]) | .wind = "🍃" + ($weather | split(" ") | .[3]) | .text = .icon + " " + .temp + " " + .prec + " " + .wind | {text}' < <(echo '{}')
        exit
    fi
    sleep 2
done

echo '{"text": ""}'
