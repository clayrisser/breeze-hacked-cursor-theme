#!/bin/sh
# Builds the Breeze Hacked Xcursor theme from src/cursors.svg.
#
# Each cursor object in the SVG is rendered with inkscape at every scale,
# assembled into an Xcursor file with xcursorgen (hotspots come from the
# matching src/config/*.cursor file), aliased per src/cursorList, and staged
# under ./<Theme_Name>/ ready for `make install`.

set -eu

cd "$(dirname -- "$0")"

rawsvg=src/cursors.svg
index=src/index.theme
aliases=src/cursorList
configdir=src/config
size=24 # cursor size at 1x scale
dpi=90  # render dpi at 1x scale
scales="1 1.5 2"

echo "Checking requirements..."
for f in "$rawsvg" "$index" "$aliases"; do
  if [ ! -f "$f" ]; then
    printf 'FAIL: %s is missing\n' "$f" >&2
    exit 1
  fi
done
for tool in inkscape xcursorgen; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    printf "FAIL: %s must be installed (or run 'make build/docker')\n" "$tool" >&2
    exit 1
  fi
done

output=$(sed -n 's/^Name=//p' "$index" | head -n 1 | tr ' ' '_')
if [ -z "$output" ]; then
  printf 'FAIL: no Name= entry in %s\n' "$index" >&2
  exit 1
fi

echo "Making folders..."
for scale in $scales; do
  mkdir -p "build/x$scale"
done
mkdir -p "$output/cursors"

cursornames=
for config in "$configdir"/*.cursor; do
  name=${config##*/}
  cursornames="$cursornames ${name%.cursor}"
done

# Print the frame names a cursor renders to: the cursor name itself for
# static cursors, <name>-01 .. <name>-NN for animated ones (one line per
# size-$size row in the cursor config).
frames() {
  count=$(grep -c "^$size " "$configdir/$1.cursor" || true)
  if [ "$count" -le 1 ]; then
    echo "$1"
  else
    i=1
    while [ "$i" -le "$count" ]; do
      printf '%s-%02d\n' "$1" "$i"
      i=$((i + 1))
    done
  fi
}

jobs=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 4)
echo "Rendering cursor pixmaps ($jobs jobs)..."
running=0
for scale in $scales; do
  scaledpi=$(awk -v dpi="$dpi" -v scale="$scale" 'BEGIN { printf "%g", dpi * scale }')
  for name in $cursornames; do
    for frame in $(frames "$name"); do
      # SELF_CALL works around inkscape >= 1.2 refusing concurrent instances.
      SELF_CALL=x inkscape "$rawsvg" -i "$frame" -d "$scaledpi" \
        -o "build/x$scale/$frame.png" >/dev/null 2>&1 &
      running=$((running + 1))
      if [ "$running" -ge "$jobs" ]; then
        wait
        running=0
      fi
    done
  done
done
wait

# Renders run in background jobs, so failures surface here instead.
missing=0
for scale in $scales; do
  for name in $cursornames; do
    for frame in $(frames "$name"); do
      if [ ! -s "build/x$scale/$frame.png" ]; then
        printf 'FAIL: build/x%s/%s.png was not rendered\n' "$scale" "$frame" >&2
        missing=$((missing + 1))
      fi
    done
  done
done
[ "$missing" -eq 0 ] || exit 1

echo "Generating cursor theme..."
for name in $cursornames; do
  awk -v size="$size" -v scales="$scales" -v name="$name" '
    $1 == size { n++; x[n] = $2; y[n] = $3; delay[n] = $5 }
    END {
      m = split(scales, scale, " ")
      for (s = 1; s <= m; s++)
        for (i = 1; i <= n; i++) {
          frame = n > 1 ? sprintf("%s-%02d", name, i) : name
          line = sprintf("%.0f %.0f %.0f x%s/%s.png", \
            size * scale[s], x[i] * scale[s], y[i] * scale[s], scale[s], frame)
          if (n > 1) line = line " " (delay[i] != "" ? delay[i] : 30)
          print line
        }
    }
  ' "$configdir/$name.cursor" | xcursorgen -p build - "$output/cursors/$name"
done

echo "Generating alias symlinks..."
while read -r from to; do
  [ -n "$from" ] || continue
  if [ -e "$output/cursors/$from" ] && [ ! -h "$output/cursors/$from" ]; then
    printf 'FAIL: alias %s collides with a real cursor\n' "$from" >&2
    exit 1
  fi
  ln -sf "$to" "$output/cursors/$from"
done <"$aliases"

echo "Copying theme index..."
cp "$index" "$output/index.theme"

echo "COMPLETE ($output)"
