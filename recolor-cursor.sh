#!/bin/sh
# Recolors the Breeze Hacked cursor theme's source SVG in place.

set -eu

default_accent_color="#79f5f3"       # cyan accents
default_base_color="#192629"         # dark filled-in spots
default_border_color="#666666"       # grey border
default_wayland_logo_color="#ffffff" # white W in the Wayland logo
default_x_logo_color="#fcfcfc"       # white X in the X logo

print_usage() {
  cat <<EOF
$(basename "$0") -- recolor the Breeze Hacked cursor theme's source svg file

USAGE:
  ./$(basename "$0") [OPTIONS]

OPTIONS:
  --help                          Print this message
  --accent-color <hex code>       Recolor the cyan accents
  --base-color <hex code>         Recolor the dark background
  --border-color <hex code>       Recolor the grey border
  --logo-color <hex code>         Recolor the X in the X logo cursor and the W
                                  in the Wayland logo cursor

  <hex code>                      A hex code representing a color beginning
                                  with a pound sign
EOF
}

validate_hex_code() {
  case "${1:-}" in
  '#'[0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f][0-9A-Fa-f]) ;;
  *)
    printf 'invalid input: %s\n' "${1:-<missing>}" >&2
    echo 'input must be a valid hex code beginning with a pound sign' >&2
    exit 1
    ;;
  esac
}

accent_color=$default_accent_color
base_color=$default_base_color
border_color=$default_border_color
wayland_logo_color=$default_wayland_logo_color
x_logo_color=$default_x_logo_color

while [ $# -gt 0 ]; do
  case "$1" in
  -h | --help)
    print_usage
    exit 0
    ;;
  --accent-color)
    shift
    validate_hex_code "${1:-}"
    accent_color=$1
    ;;
  --base-color)
    shift
    validate_hex_code "${1:-}"
    base_color=$1
    ;;
  --border-color)
    shift
    validate_hex_code "${1:-}"
    border_color=$1
    ;;
  --logo-color)
    shift
    validate_hex_code "${1:-}"
    wayland_logo_color=$1
    x_logo_color=$1
    ;;
  *)
    printf 'invalid option: %s\n' "$1" >&2
    print_usage >&2
    exit 1
    ;;
  esac
  shift
done

svg_path="$(dirname -- "$0")/src/cursors.svg"

# POSIX sed has no -i; write to a temp file and move it into place.
tmp=$(mktemp)
sed \
  -e "s/$default_accent_color/$accent_color/g" \
  -e "s/$default_base_color/$base_color/g" \
  -e "s/$default_border_color/$border_color/g" \
  -e "s/$default_wayland_logo_color/$wayland_logo_color/g" \
  -e "s/$default_x_logo_color/$x_logo_color/g" \
  "$svg_path" >"$tmp"
mv "$tmp" "$svg_path"

echo "Successfully recolored $svg_path"
