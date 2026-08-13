#!/usr/bin/env bats
load helper.sh

@test "index.theme is staged into the theme" {
  [ -f "$THEME_DIR/index.theme" ]
}

@test "index.theme matches the source index" {
  cmp -s "$PROJECT_ROOT/src/index.theme" "$THEME_DIR/index.theme"
}

@test "index.theme declares the icon theme section and name" {
  head -n 1 "$THEME_DIR/index.theme" | grep -q '^\[Icon Theme\]$'
  grep -q '^Name=Breeze Hacked$' "$THEME_DIR/index.theme"
}
