# Shared helpers for the bats suite. POSIX sh.
PROJECT_ROOT="${PROJECT_ROOT:-$(cd "${BATS_TEST_DIRNAME:-$(dirname -- "$0")}/.." && pwd)}"
THEME_NAME=Breeze_Hacked
THEME_DIR="$PROJECT_ROOT/$THEME_NAME"
CURSORS_DIR="$THEME_DIR/cursors"

# Print the name of every cursor the theme should ship, one per line.
cursor_names() {
  for config in "$PROJECT_ROOT"/src/config/*.cursor; do
    basename "$config" .cursor
  done
}
