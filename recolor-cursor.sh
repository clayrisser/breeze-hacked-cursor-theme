#!/usr/bin/env bash

# Safety options
set -o errtrace \
  -o errexit \
  -o nounset \
  -o xtrace \
  -o pipefail

readonly DEFAULT_ACCENT_COLOR="#79f5f3"       # Cyan accents
readonly DEFAULT_BASE_COLOR="#192629"         # Dark filled-in spots
readonly DEFAULT_BORDER_COLOR="#666666"       # grey border
readonly DEFAULT_WAYLAND_LOGO_COLOR="#ffffff" # white W in Wayland logo
readonly DEFAULT_X_LOGO_COLOR="#fcfcfc"       # white X in X logo

print_usage() {
  cat <<EOF
    $(basename "$0") -- script for recoloring the Breeze Hacked cursor theme's source svg file
  
    USAGE:
      ./$(basename "$0") [OPTIONS]

    OPTIONS:
      --help                          Print this message
      --accent-color <hex code>       Recolor the cyan accents
      --base-color <hex code>         Recolor the dark background
      --border-color <hex code>       Recolor the grey border
      --logo-color <hex code>         Recolor the X in the X logo cursor and the W in the Wayland logo cursor

      <hex code>                      A hex code representing a color beginning with a pound sign
EOF
}

invalid_input() {
  echo "invalid option: ${1}"
  print_usage
  exit 1
}

validate_hex_code() {
  if ! [[ "$1" =~ \#[[:xdigit:]]{6} ]]; then
    echo "invalid input: ${1}"
    echo "input must be a valid hex code beginning with a pound sign"
    exit 1
  fi
}

# Parse options
while getopts ":h-:" optchar; do
  case "$optchar" in
  h)
    print_usage
    exit
    ;;
  -)
    case "$OPTARG" in
    help)
      print_usage
      exit
      ;;
    accent-color)
      validate_hex_code "${!OPTIND}"
      accent_color="${!OPTIND}"
      ;;
    base-color)
      validate_hex_code "${!OPTIND}"
      base_color="${!OPTIND}"
      ;;
    border-color)
      validate_hex_code "${!OPTIND}"
      border_color="${!OPTIND}"
      ;;
    logo-color)
      validate_hex_code "${!OPTIND}"
      logo_color="${!OPTIND}"
      ;;
    *)
      invalid_input "${OPTARG}"
      ;;
    esac
    ;;
  *)
    invalid_input "${OPTARG}"
    ;;
  esac

  # Every valid option except for --help takes a value
  # skip it so it is not treated like a flag
  OPTIND=$((OPTIND + 1))
done

readonly accent_color=${accent_color:-$DEFAULT_ACCENT_COLOR}
readonly base_color=${base_color:-$DEFAULT_BASE_COLOR}
readonly border_color=${border_color:-$DEFAULT_BORDER_COLOR}
readonly logo_color=${logo_color:-$DEFAULT_WAYLAND_LOGO_COLOR}

# Declared and assigned separately to avoid masking return values
SVG_PATH="$(dirname "$0")/src/cursors.svg"
declare -r SVG_PATH

# Recolor
sed -i "s/$DEFAULT_ACCENT_COLOR/$accent_color/g; \
        s/$DEFAULT_BASE_COLOR/$base_color/g; \
        s/$DEFAULT_BORDER_COLOR/$border_color/g; \
        s/($DEFAULT_WAYLAND_LOGO_COLOR|$DEFAULT_X_LOGO_COLOR)/$logo_color/g;" \
  "$SVG_PATH"

echo "Successfully recolored $SVG_PATH"
