#!/bin/bash
## Take a screenshot with hyprshot and annotate with satty

filename=$(hyprshot --mode region --freeze -- echo)
satty --filename "$filename" --output-filename "$(dirname "$filename")/$(basename "$filename" .png)"_annotated.png
