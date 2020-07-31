#!/usr/bin/env bash

OPTIPNG="/usr/bin/optipng"

SRC_FILE="sidebar-assets.svg"
ASSETS_DIR="sidebar-assets"
INDEX="sidebar-assets.txt"

function inkscape() {
  command flatpak run org.inkscape.Inkscape "$@"
}

mkdir -p "$ASSETS_DIR"

for i in `cat $INDEX`
do 
if [ -f "$ASSETS_DIR/$i.png" ]; then
    echo "$ASSETS_DIR/$i.png exists."
else
    echo
    echo "Rendering $ASSETS_DIR/$i.png"
    inkscape --export-id=$i \
              --export-id-only \
              --export-filename="$ASSETS_DIR/$i.png" "$SRC_FILE" > /dev/null 2>&1
    $OPTIPNG -o7 --quiet "$ASSETS_DIR/$i.png" 
fi
if [ -f "$ASSETS_DIR/$i@2.png" ]; then
    echo "$ASSETS_DIR/$i@2.png exists."
else
    echo
    echo "Rendering $ASSETS_DIR/$i@2.png"
    inkscape --export-id=$i \
              --export-dpi=180 \
              --export-id-only \
              --export-filename="$ASSETS_DIR/$i@2.png" "$SRC_FILE" > /dev/null 2>&1
    $OPTIPNG -o7 --quiet "$ASSETS_DIR/$i@2.png" 
fi
done
exit 0
