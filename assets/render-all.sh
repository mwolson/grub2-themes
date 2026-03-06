#!/bin/bash

THEMES=("color" "white" "whitesur" "select")
RESOLUTIONS=("1080p" "2k" "4k")

for theme in "${THEMES[@]}"; do
  for resolution in "${RESOLUTIONS[@]}"; do
    echo "./render-assets.sh \"$theme\" \"$resolution\": "
    ./render-assets.sh "$theme" "$resolution"
    if [[ "$theme" != "select" ]]; then
      echo "./render-custom-icons.sh \"$theme\" \"$resolution\": "
      ./render-custom-icons.sh "$theme" "$resolution"
    fi
  done
done
