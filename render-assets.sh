#!/usr/bin/env bash

OPTIPNG="/usr/bin/optipng"

REPO_DIR=$(cd $(dirname $0) && pwd)
ASRC_DIR="${REPO_DIR}/src/assets"
CURSOR_DIR="${REPO_DIR}/cursors"

render_thumbnail() {
  local dest=$1
  local color=$2

  if [ -f "$ASRC_DIR/$1/thumbnail$2.png" ]; then
    echo "$ASRC_DIR/$1/thumbnail$2.png exists."
  else
    echo
    echo "Rendering $ASRC_DIR/$1/thumbnail$2.png"
    inkscape --export-id="thumbnail$2" \
                 --export-id-only \
                 --export-filename="$ASRC_DIR/$1/thumbnail$2.png" "$ASRC_DIR/$1/thumbnail.svg" > /dev/null 2>&1
    $OPTIPNG -o7 --quiet "$ASRC_DIR/$1/thumbnail$2.png"
  fi
}

for color in '-light' '-dark' ; do
  render_thumbnail "${dest:-gtk-3.0}" "${color}"
done

echo "Rendering Cursor assets"
cd "$CURSOR_DIR"
./build.sh

exit 0
