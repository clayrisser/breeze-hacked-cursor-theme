#!/usr/bin/env bats
load helper.sh

setup_file() {
  TEST_DESTDIR="$BATS_FILE_TMPDIR/destdir"
  export TEST_DESTDIR
}

@test "install stages the theme under DESTDIR" {
  run make -C "$PROJECT_ROOT" install DESTDIR="$TEST_DESTDIR" PREFIX=/usr
  [ "$status" -eq 0 ]
  [ -f "$TEST_DESTDIR/usr/share/icons/$THEME_NAME/index.theme" ]
  [ -f "$TEST_DESTDIR/usr/share/icons/$THEME_NAME/cursors/default" ]
  [ -h "$TEST_DESTDIR/usr/share/icons/$THEME_NAME/cursors/left_ptr" ]
}

@test "reinstalling does not nest the theme directory" {
  run make -C "$PROJECT_ROOT" install DESTDIR="$TEST_DESTDIR" PREFIX=/usr
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_DESTDIR/usr/share/icons/$THEME_NAME/$THEME_NAME" ]
}

@test "installed theme matches the built theme" {
  diff -r "$THEME_DIR" "$TEST_DESTDIR/usr/share/icons/$THEME_NAME"
}

@test "uninstall removes the installed theme" {
  run make -C "$PROJECT_ROOT" uninstall DESTDIR="$TEST_DESTDIR" PREFIX=/usr
  [ "$status" -eq 0 ]
  [ ! -e "$TEST_DESTDIR/usr/share/icons/$THEME_NAME" ]
  [ -d "$TEST_DESTDIR/usr/share/icons" ]
}
