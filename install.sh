#!/usr/bin/env bash

set -ueo pipefail

REPO_DIR=$(cd $(dirname $0) && pwd)
SRC_DIR="${REPO_DIR}/src"

ROOT_UID=0
DEST_DIR=

# Destination directory
if [ "$UID" -eq "$ROOT_UID" ]; then
  DEST_DIR="/usr/share/themes"
  PLANK_DIR="/usr/share/plank/themes"
  APP_DIR="/usr/share/applications"
else
  DEST_DIR="$HOME/.themes"
  PLANK_DIR="$HOME/.local/share/plank/themes"
  APP_DIR="$HOME/.local/share/applications"
fi

THEME_NAME=MaryamOS
COLOR_VARIANTS=('-light' '-dark')
OPACITY_VARIANTS=('' '-solid')
ICON_VARIANTS=('' '-normal' '-gnome' '-ubuntu' '-arch' '-manjaro' '-fedora' '-debian' '-void')


#COLORS
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # warning color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# echo like ...  with  flag type  and display message  colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@:2}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@:2}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@:2}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@:2}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Specify activities icon variant(s) for gnome-shell [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian|void] (Default: standard variant)"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

parse_sass() {
  cd "${REPO_DIR}"
  ./parse-sass.sh
}

install() {
  local dest=${1}
  local name=${2}
  local color=${3}
  local opacity=${4}
  local icon=${5}

  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}
  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}

  local THEME_DIR=${1}/${2}${3}${4}${5}

  [[ -d ${THEME_DIR} ]] && rm --recursive --force ${THEME_DIR}

  prompt --info "Installing '${THEME_DIR}'..."

  mkdir --parents                                                                                          "${THEME_DIR}"
  cp --update --recursive "${REPO_DIR}/LICENSE"                                                            "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                                "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                                         "${THEME_DIR}/index.theme"
  echo "Name=${name}${color}${opacity}" >>                                                                 "${THEME_DIR}/index.theme"
  echo "Comment=An Stylish Gtk+ gnome-shell and icon theme based on MacOS Design" >>                       "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "" >>                                                                                               "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                                            "${THEME_DIR}/index.theme"
  echo "GtkTheme=${name}${color}${opacity}" >>                                                             "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${name}${color}${opacity}" >>                                                        "${THEME_DIR}/index.theme"

  # install gnome-shell theme.
  # set right icon for activity panel.
  local var="\$icon-logo: '${icon}';"; # set the string to be replace the template in scss files.
  sed --in-place "1s/.*/${var}/"  "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}.scss" # use sed to fill template.
  
  # generate css files.
  parse_sass
  
  # copy css files.
  mkdir --parents                                                                                          "${THEME_DIR}/gnome-shell"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/source-assets"/*                                  "${THEME_DIR}/gnome-shell"
  cp --update --recursive "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}.css"                  "${THEME_DIR}/gnome-shell/gnome-shell.css"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/common-assets"                                    "${THEME_DIR}/gnome-shell/assets"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/assets${color}"/*.svg                             "${THEME_DIR}/gnome-shell/assets"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/assets${color}/activities/activities${icon}"*.svg "${THEME_DIR}/gnome-shell/assets/"

  # install plank dock theme.
  mkdir --parents                                                                                         "${THEME_DIR}/plank"
  cp --update --recursive "${SRC_DIR}/other/plank/theme${color}"/*.theme                                  "${THEME_DIR}/plank"

  mkdir --parents                                                                                         "${PLANK_DIR}/${2}${3}"
  cp --update --recursive "${SRC_DIR}/other/plank/theme${color}"/*.theme                                  "${PLANK_DIR}/${2}${3}"
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        prompt --info "Destination directory does not exist. Let's make a new one..."
        mkdir --parents ${dest}
      fi
      shift 2
      ;;
    -n|--name)
      name="${2}"
      shift 2
      ;;
    --snap)
      snap='true'
      shift 1
      ;;
    -s|--size)
      size='true'
      shift 1
      ;;
    -o|--opacity)
      shift
      for opacity in "${@}"; do
        case "${opacity}" in
          standard)
            opacities+=("${OPACITY_VARIANTS[0]}")
            shift
            ;;
          solid)
            opacities+=("${OPACITY_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt --error "ERROR: Unrecognized opacity variant '$1'."
            prompt --info "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -c|--color)
      shift
      for color in "${@}"; do
        case "${color}" in
          light)
            colors+=("${COLOR_VARIANTS[0]}")
            shift
            ;;
          dark)
            colors+=("${COLOR_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt --error "ERROR: Unrecognized color variant '$1'."
            prompt --info "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          standard)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          normal)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          gnome)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          ubuntu)
            icons+=("${ICON_VARIANTS[3]}")
            shift
            ;;
          arch)
            icons+=("${ICON_VARIANTS[4]}")
            shift
            ;;
          manjaro)
            icons+=("${ICON_VARIANTS[5]}")
            shift
            ;;
          fedora)
            icons+=("${ICON_VARIANTS[6]}")
            shift
            ;;
          debian)
            icons+=("${ICON_VARIANTS[7]}")
            shift
            ;;
          void)
            icons+=("${ICON_VARIANTS[8]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt --error "ERROR: Unrecognized icon variant '$1'."
            prompt --info "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt --error "ERROR: Unrecognized installation option '$1'."
      prompt --info "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

# install theme
install_theme() {
for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
      install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${icon}"
    done
  done
done
}

# Install theme.
install_theme

# Install cursors
echo
prompt --info "Installing cursors..."

cd "${REPO_DIR}/cursors"
./install.sh

prompt --success "Installing cursors ... DONE"

# Install Icons
echo
prompt --info "Installing icons..."

cd "${REPO_DIR}/icons"
./install.sh

prompt --success "Installing icons ... DONE"

echo
prompt --success "Done."
