#!/usr/bin/env bash

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/icons"
else
  DEST_DIR="$HOME/.local/share/icons"
fi

SRC_DIR="$(cd $(dirname $0) && pwd)"

THEME_NAME="MaryamOS-BigSur"

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local dest=${1}
  local name=${2}

  local THEME_DIR="${dest}/${name}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir --parents                                   "${THEME_DIR}"
  cp --recursive "${SRC_DIR}/src/index.theme"       "${THEME_DIR}"

  cd ${THEME_DIR}

  cp --recursive "${SRC_DIR}/src/apps"              "${THEME_DIR}"
  cp --recursive "${SRC_DIR}/links/apps"            "${THEME_DIR}"

  cd "${THEME_DIR}"
  ln --symbolic --force apps apps@2x

  cd ${dest}
  gtk-update-icon-cache "${name}"
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "ERROR: Destination directory does not exist."
        exit 1
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
  shift
done

install_theme() {
  install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}"
}

install_theme
