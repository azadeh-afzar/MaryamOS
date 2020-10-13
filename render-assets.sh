#!/usr/bin/env bash

REPO_DIR=$(cd $(dirname $0) && pwd)
CURSOR_DIR="${REPO_DIR}/cursors"

echo "Rendering Cursor assets"
cd "$CURSOR_DIR"
./build.sh

exit 0
