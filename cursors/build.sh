#!/usr/bin/env bash

CURRENT_DIR=$(cd $(dirname $0) && pwd)

cd "${CURRENT_DIR}/BigSur"
./build.sh

cd "${CURRENT_DIR}/McMojave"
./build.sh
