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

THEME_NAME="MaryamOS-Icons"
COLOR_VARIANTS=('' '-dark')

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
  local color=${3}

  local THEME_DIR="${dest}/${name}${color}"

  [[ -d "${THEME_DIR}" ]] && rm -rf "${THEME_DIR}"

  echo "Installing '${THEME_DIR}'..."

  mkdir --parents                                                                                       "${THEME_DIR}"                                                   ${THEME_DIR}
  cp --recursive "${SRC_DIR}/src/index.theme"                                                           "${THEME_DIR}"

  if [[ "${DESKTOP_SESSION}" == '/usr/share/xsessions/plasma' && "${color}" == '' ]]; then
    sed --in-place "s/Adwaita/breeze/g" "${THEME_DIR}/index.theme"
  fi

  if [[ $DESKTOP_SESSION == '/usr/share/xsessions/plasma' && ${color} == '-dark' ]]; then
    sed --in-place "s/Adwaita/breeze-dark/g" "${THEME_DIR}/index.theme"
  fi

  cd ${THEME_DIR}
  sed --in-place "s/${name}/${name}${color}/g" index.theme

  if [[ ${color} == '' ]]; then
    mkdir --parents                                                                                   "${THEME_DIR}/status"
    cp --recursive "${SRC_DIR}/src"/{actions,animations,apps,categories,devices,emblems,mimes,places} "${THEME_DIR}"
    cp --recursive "${SRC_DIR}/src/status"/{16,22,24,32,symbolic}                                     "${THEME_DIR}/status"
    cp --recursive "${SRC_DIR}/links"/{actions,apps,devices,emblems,mimes,places,status}              "${THEME_DIR}"
  fi

  if [[ "${color}" == '' && "${DESKTOP_SESSION}" == '/usr/share/xsessions/budgie-desktop' ]]; then
    cp --recursive "${SRC_DIR}/src/status/symbolic-budgie"/*.svg                                      "${THEME_DIR}/status/symbolic"
  fi

  if [[ ${color} == '-dark' ]]; then
    mkdir --parents                                                                                   "${THEME_DIR}"/{apps,categories,emblems,devices,mimes,places,status}

    cp --recursive "${SRC_DIR}/src/actions"                                                           "${THEME_DIR}"
    cp --recursive "${SRC_DIR}/src/apps/symbolic"                                                     "${THEME_DIR}/apps"
    cp --recursive "${SRC_DIR}/src/categories/symbolic"                                               "${THEME_DIR}/categories"
    cp --recursive "${SRC_DIR}/src/emblems/symbolic"                                                  "${THEME_DIR}/emblems"
    cp --recursive "${SRC_DIR}/src/mimes/symbolic"                                                    "${THEME_DIR}/mimes"
    cp --recursive "${SRC_DIR}/src/devices"/{16,22,24,symbolic}                                       "${THEME_DIR}/devices"
    cp --recursive "${SRC_DIR}/src/places"/{16,22,24,symbolic}                                        "${THEME_DIR}/places"
    cp --recursive "${SRC_DIR}/src/status"/{16,22,24,symbolic}                                        "${THEME_DIR}/status"

    # Change icon color for dark theme
    sed --in-place "s/#363636/#ffffff/g" "${THEME_DIR}"/{actions,apps,categories,emblems,devices,mimes,places,status}/symbolic/*

    cp --recursive "${SRC_DIR}/links/actions"/{16,22,24,symbolic}                                    "${THEME_DIR}/actions"
    cp --recursive "${SRC_DIR}/links/devices"/{16,22,24,symbolic}                                    "${THEME_DIR}/devices"
    cp --recursive "${SRC_DIR}/links/places"/{16,22,24,symbolic}                                     "${THEME_DIR}/places"
    cp --recursive "${SRC_DIR}/links/status"/{16,22,24,symbolic}                                     "${THEME_DIR}/status"
    cp --recursive "${SRC_DIR}/links/apps/symbolic"                                                  "${THEME_DIR}/apps"
    cp --recursive "${SRC_DIR}/links/mimes/symbolic"                                                 "${THEME_DIR}/mimes"

    cd ${dest}
    ln --symbolic "../${name}/animations"                                                            "${name}-dark/animations"
    ln --symbolic "../../${name}/categories/32"                                                      "${name}-dark/categories/32"
    ln --symbolic "../../${name}/emblems/16"                                                         "${name}-dark/emblems/16"
    ln --symbolic "../../${name}/emblems/22"                                                         "${name}-dark/emblems/22"
    ln --symbolic "../../${name}/emblems/24"                                                         "${name}-dark/emblems/24"
    ln --symbolic "../../${name}/mimes/scalable"                                                     "${name}-dark/mimes/scalable"
    ln --symbolic "../../${name}/apps/scalable"                                                      "${name}-dark/apps/scalable"
    ln --symbolic "../../${name}/devices/scalable"                                                   "${name}-dark/devices/scalable"
    ln --symbolic "../../${name}/places/scalable"                                                    "${name}-dark/places/scalable"
    ln --symbolic "../../${name}/status/32"                                                          "${name}-dark/status/32"

    cd ${THEME_DIR}
    sed --in-place "s/Numix-Circle-Light/Numix-Circle/g" "index.theme"
  fi

  cd "${THEME_DIR}"
  ln --symbolic --force actions actions@2x
  ln --symbolic --force animations animations@2x
  ln --symbolic --force apps apps@2x
  ln --symbolic --force categories categories@2x
  ln --symbolic --force devices devices@2x
  ln --symbolic --force emblems emblems@2x
  ln --symbolic --force mimes mimes@2x
  ln --symbolic --force places places@2x
  ln --symbolic --force status status@2x

  cd ${dest}
  gtk-update-icon-cache "${name}${color}"
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
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}"
  done
}

install_theme
