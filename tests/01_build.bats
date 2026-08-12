#!/usr/bin/env bats
load helper.sh

@test "theme directory is built" {
  [ -d "$THEME_DIR" ]
  [ -d "$CURSORS_DIR" ]
}

@test "every cursor config produced a real cursor file" {
  for name in $(cursor_names); do
    [ ! -h "$CURSORS_DIR/$name" ] || { echo "cursor is a symlink: $name" >&2 && return 1; }
    [ -f "$CURSORS_DIR/$name" ] || { echo "missing cursor: $name" >&2 && return 1; }
  done
}

@test "every cursor file is a valid Xcursor file" {
  for name in $(cursor_names); do
    magic=$(head -c 4 "$CURSORS_DIR/$name")
    [ "$magic" = "Xcur" ] || { echo "bad magic in $name: $magic" >&2 && return 1; }
  done
}

@test "every alias in cursorList is a symlink resolving to a real cursor" {
  while read -r from to; do
    [ -n "$from" ] || continue
    [ -h "$CURSORS_DIR/$from" ] || { echo "missing alias: $from" >&2 && return 1; }
    [ -f "$CURSORS_DIR/$from" ] || { echo "dangling alias: $from -> $to" >&2 && return 1; }
  done <"$PROJECT_ROOT/src/cursorList"
}

@test "cursors directory contains exactly the configs plus aliases" {
  { cursor_names && awk '{print $1}' "$PROJECT_ROOT/src/cursorList"; } |
    sort >"$BATS_TEST_TMPDIR/expected"
  ls "$CURSORS_DIR" | sort >"$BATS_TEST_TMPDIR/actual"
  diff -u "$BATS_TEST_TMPDIR/expected" "$BATS_TEST_TMPDIR/actual"
}
