#!/usr/bin/env bash

OPTIPNG="/usr/bin/optipng"

SRC_FILE="windows-assets.svg"
ASSETS_DIR="titlebutton-alt-small"
INDEX="assets.txt"

function inkscape() {
  command flatpak run org.inkscape.Inkscape "$@"
}

mkdir -p "$ASSETS_DIR"

for i in `cat $INDEX` ; do
for d in '' '-dark' ; do

## alt small titlebutton
if [ -f "$ASSETS_DIR/$i$d.png" ]; then
    echo "$ASSETS_DIR/$i$d.png exists."
else
    echo
    echo "Rendering $ASSETS_DIR/$i$d.png"
    inkscape --export-id=$i-alt-small$d \
              --export-id-only \
              --export-filename="$ASSETS_DIR/$i$d.png" "$SRC_FILE" > /dev/null 2>&1
    $OPTIPNG -o7 --quiet "$ASSETS_DIR/$i$d.png" 
fi

if [ -f "$ASSETS_DIR/$i$d@2.png" ]; then
    echo "$ASSETS_DIR/$i$d@2.png exists."
else
    echo
    echo "Rendering $ASSETS_DIR/$i$d@2.png"
    inkscape --export-id=$i-alt-small$d \
              --export-dpi=180 \
              --export-id-only \
              --export-filename="$ASSETS_DIR/$i$d@2.png" "$SRC_FILE" > /dev/null 2>&1
    $OPTIPNG -o7 --quiet "$ASSETS_DIR/$i$d@2.png" 
fi

done
done
exit 0
