#!/bin/bash

set -euo pipefail

variant="${1:-}"
resolution="${2:-}"

case "$variant" in
    color|white|whitesur)
        ;;
    *)
        echo "Please use 'color', 'white', or 'whitesur'"
        exit 1
        ;;
esac

case "$resolution" in
    1080p)
        size=32
        ;;
    2k|2K)
        size=48
        resolution="2k"
        ;;
    4k|4K)
        size=64
        resolution="4k"
        ;;
    *)
        echo "Please use either '1080p', '2k' or '4k'"
        exit 1
        ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$script_dir/custom-icons"
output_dir="$script_dir/assets-$variant/icons-$resolution"
optipng_bin="$(command -v optipng || true)"

mkdir -p "$output_dir"

shopt -s nullglob
icons=("$source_dir"/*.png "$source_dir"/*.svg)

if [[ ${#icons[@]} -eq 0 ]]; then
    exit 0
fi

if printf '%s\n' "${icons[@]}" | grep -q '\.svg$' && ! command -v rsvg-convert >/dev/null 2>&1; then
    echo "rsvg-convert is required for SVG icon rendering"
    exit 1
fi

if printf '%s\n' "${icons[@]}" | grep -q '\.png$' && ! command -v magick >/dev/null 2>&1; then
    echo "magick is required for PNG icon rendering"
    exit 1
fi

for icon in "${icons[@]}"; do
    icon_name="$(basename "$icon")"
    icon_name="${icon_name%.*}"
    icon_path="$output_dir/$icon_name.png"

    if [[ "$icon" == *.svg ]]; then
        rsvg-convert -w "$size" -h "$size" "$icon" -o "$icon_path"
    elif [[ "$resolution" == "1080p" ]]; then
        cp "$icon" "$icon_path"
    else
        magick "$icon" -background none -resize "${size}x${size}" "PNG32:$icon_path"
    fi

    if [[ -n "$optipng_bin" ]]; then
        "$optipng_bin" -strip all -quiet "$icon_path"
    fi

    echo "Rendered $icon_path"
done
