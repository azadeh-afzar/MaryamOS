#!/usr/bin/env bash

CURRENT_DIR=$(cd $(dirname $0) && pwd)

cd "${CURRENT_DIR}/default"
./install.sh

cd "${CURRENT_DIR}/circle"
./install.sh