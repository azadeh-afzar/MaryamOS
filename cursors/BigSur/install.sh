#!/usr/bin/env bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

if [ -d "$DEST_DIR/MaryamOS-BigSur-Cursors" ]; then
  rm --recursive --force "$DEST_DIR/MaryamOS-BigSur-Cursors"
fi

cp --recursive dist "$DEST_DIR/MaryamOS-BigSur-Cursors"

echo "Finished..."

