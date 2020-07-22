#!/usr/bin/env bash

set -ueo pipefail
#set -x

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
ALT_VARIANTS=('' '-alt')
ICON_VARIANTS=('' '-normal' '-gnome' '-ubuntu' '-arch' '-manjaro' '-fedora' '-debian' '-void')

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-a, --alt VARIANTS" "Specify theme titilebutton variant(s) [standard|alt] (Default: All variants)"
  printf "  %-25s%s\n" "-s, --small VARIANTS" "Specify titilebutton size variant(s) [standard|small] (Default: standard variant)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Specify activities icon variant(s) for gnome-shell [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian|void] (Default: standard variant)"
  printf "  %-25s%s\n"     "--snap"          "Install modifed Snap application .desktop files to apply custom theme."
  printf "  %-25s%s\n" "-g, --gdm" "Install GDM theme, this option need root user authority! please run this with sudo"
  printf "  %-25s%s\n" "-r, --revert" "revert GDM theme, this option need root user authority! please run this with sudo"
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
  local alt=${5}
  local icon=${6}

  [[ ${color} == '-light' ]] && local ELSE_LIGHT=${color}
  [[ ${color} == '-dark' ]] && local ELSE_DARK=${color}

  local THEME_DIR=${1}/${2}${3}${4}${5}${6}

  [[ -d ${THEME_DIR} ]] && rm --recursive --force ${THEME_DIR}

  echo "Installing '${THEME_DIR}'..."

  mkdir --parents                                                                                "${THEME_DIR}"
  cp --update --recursive "${REPO_DIR}/LICENSE"                                                            "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                               "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                        "${THEME_DIR}/index.theme"
  echo "Name=${name}${color}${opacity}" >>                                                "${THEME_DIR}/index.theme"
  echo "Comment=An Stylish Gtk+ theme based on Elegant Design" >>                         "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                "${THEME_DIR}/index.theme"
  echo "" >>                                                                              "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                           "${THEME_DIR}/index.theme"
  echo "GtkTheme=${name}${color}${opacity}" >>                                            "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${name}${color}${opacity}" >>                                       "${THEME_DIR}/index.theme"
  echo "IconTheme=McMojave-circle" >>                                                     "${THEME_DIR}/index.theme"
  echo "CursorTheme=McMojave-circle" >>                                                   "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                     "${THEME_DIR}/index.theme"

  # install Gnome shell theme.
  # set right icon for activity panel
  local var="\$icon-logo: '${icon}';";
  sed --in-place "1s/.*/${var}/"  "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}.scss"
  # generate css files.
  parse_sass
  # copy css files.
  mkdir --parents                                                                                "${THEME_DIR}/gnome-shell"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/source-assets"/*                                  "${THEME_DIR}/gnome-shell"
  cp --update --recursive "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}.css"                  "${THEME_DIR}/gnome-shell/gnome-shell.css"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/common-assets"                                    "${THEME_DIR}/gnome-shell/assets"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/assets${color}"/*.svg                             "${THEME_DIR}/gnome-shell/assets"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/assets${color}/activities/activities${icon}"*.svg "${THEME_DIR}/gnome-shell/assets/"

  # install gtk3 theme.
  mkdir --parents                                                                                 "${THEME_DIR}/gtk-3.0"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/common-assets/assets"                                  "${THEME_DIR}/gtk-3.0"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/windows-assets/titlebutton${alt}"                      "${THEME_DIR}/gtk-3.0/windows-assets"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/thumbnail${color}.png"                                 "${THEME_DIR}/gtk-3.0/thumbnail.png"
  cp --update --recursive "${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}.css"                                  "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  if [[ ${color} == '-light' ]]; then
    cp --update --recursive "${SRC_DIR}/main/gtk-3.0/gtk-light${opacity}.css"                               "${THEME_DIR}/gtk-3.0/gtk.css"
  else
    cp --update --recursive "${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}.css"                                "${THEME_DIR}/gtk-3.0/gtk.css"
  fi

  glib-compile-resources --sourcedir="${THEME_DIR}/gtk-3.0" --target="${THEME_DIR}/gtk-3.0/gtk.gresource" "${SRC_DIR}/main/gtk-3.0/gtk.gresource.xml"
  rm --recursive --force                                                                                   "${THEME_DIR}/gtk-3.0/{assets,windows-assets,gtk.css,gtk-dark.css}"
  echo '@import url("resource:///org/gnome/Mcata-theme/gtk.css");' >>                      "${THEME_DIR}/gtk-3.0/gtk.css"
  echo '@import url("resource:///org/gnome/Mcata-theme/gtk-dark.css");' >>                 "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  # install plank dock theme.
  mkdir --parents                                                                                 "${THEME_DIR}/plank"
  cp --update --recursive "${SRC_DIR}/other/plank/theme${color}"/*.theme                                    "${THEME_DIR}/plank"

  mkdir --parents                                                                                 "${PLANK_DIR}/${2}${3}"
  cp --update --recursive "${SRC_DIR}/other/plank/theme${color}"/*.theme                                    "${PLANK_DIR}/${2}${3}"
}

# Backup and install files related to GDM theme

GS_THEME_FILE="/usr/share/gnome-shell/gnome-shell-theme.gresource"
SHELL_THEME_FOLDER="/usr/share/gnome-shell/theme"
ETC_THEME_FOLDER="/etc/alternatives"
ETC_THEME_FILE="/etc/alternatives/gdm3.css"
UBUNTU_THEME_FILE="/usr/share/gnome-shell/theme/ubuntu.css"
UBUNTU_NEW_THEME_FILE="/usr/share/gnome-shell/theme/gnome-shell.css"

install_gdm() {
  local GDM_THEME_DIR="${1}/${2}${3}${4}"

  echo
  echo "Installing ${2}${3}${4} gdm theme..."

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    echo "Installing '$GS_THEME_FILE'..."
    cp --archive --no-clobber "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/main/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing '$UBUNTU_THEME_FILE'..."
    cp --archive --no-clobber "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    cp --archive --force "$GDM_THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing '$UBUNTU_NEW_THEME_FILE'..."
    cp --archive --no-clobber "$UBUNTU_NEW_THEME_FILE" "$UBUNTU_NEW_THEME_FILE.bak"
    cp --archive --force "$GDM_THEME_DIR"/gnome-shell/* "$SHELL_THEME_FOLDER"
  fi

  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    echo "Installing Ubuntu gnome-shell theme..."
    cp --archive --no-clobber "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm --recursive --force $SHELL_THEME_FOLDER/$THEME_NAME
    cp --update --recursive "$GDM_THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/$THEME_NAME"
    cd "$ETC_THEME_FOLDER"
    ln --symbolic "$SHELL_THEME_FOLDER/$THEME_NAME/gnome-shell.css" gdm3.css
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    echo "reverting '$GS_THEME_FILE'..."
    rm --recursive --force "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    echo "reverting '$UBUNTU_THEME_FILE'..."
    rm --recursive --force "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE.bak" ]]; then
    echo "reverting '$UBUNTU_NEW_THEME_FILE'..."
    rm --recursive --force "$UBUNTU_NEW_THEME_FILE" "$SHELL_THEME_FOLDER"/{assets,no-events.svg,process-working.svg,no-notifications.svg}
    mv "$UBUNTU_NEW_THEME_FILE.bak" "$UBUNTU_NEW_THEME_FILE"
  fi

  if [[ -f "$ETC_THEME_FILE.bak" ]]; then
    echo "reverting Ubuntu gnome-shell theme..."
    rm --recursive --force "$ETC_THEME_FILE"
    mv "$ETC_THEME_FILE.bak" "$ETC_THEME_FILE"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm --recursive --force $SHELL_THEME_FOLDER/$THEME_NAME
  fi
}

while [[ $# -gt 0 ]]; do
  case "${1}" in
    -d|--dest)
      dest="${2}"
      if [[ ! -d "${dest}" ]]; then
        echo "Destination directory does not exist. Let's make a new one..."
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
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -r|--revert)
      revert='true'
      shift 1
      ;;
    -a|--alt)
      shift
      for alt in "${@}"; do
        case "${alt}" in
          standard)
            alts+=("${ALT_VARIANTS[0]}")
            shift
            ;;
          alt)
            alts+=("${ALT_VARIANTS[1]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            echo "ERROR: Unrecognized opacity variant '$1'."
            echo "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
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
            echo "ERROR: Unrecognized opacity variant '$1'."
            echo "Try '$0 --help' for more information."
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
            echo "ERROR: Unrecognized color variant '$1'."
            echo "Try '$0 --help' for more information."
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
            echo "ERROR: Unrecognized icon variant '$1'."
            echo "Try '$0 --help' for more information."
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
      echo "ERROR: Unrecognized installation option '$1'."
      echo "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

install_theme() {
for opacity in "${opacities[@]-${OPACITY_VARIANTS[@]}}"; do
  for color in "${colors[@]-${COLOR_VARIANTS[@]}}"; do
    for alt in "${alts[@]-${ALT_VARIANTS[@]}}"; do
      for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
        install "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}" "${alt}" "${icon}"
      done
    done
  done
done
}

if [[ "${gdm:-}" != 'true' && "${revert:-}" != 'true' ]]; then
  install_theme
fi

if [[ "${gdm:-}" == 'true' && "${revert:-}" != 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  install_theme && install_gdm "${dest:-${DEST_DIR}}" "${name:-${THEME_NAME}}" "${color}" "${opacity}"
fi

if [[ "${gdm:-}" != 'true' && "${revert:-}" == 'true' && "$UID" -eq "$ROOT_UID" ]]; then
  revert_gdm
fi

# copy snap desktop files.
if [[ "${snap:-}" == 'true' ]]; then
  echo
  echo "Install custome snap pakage icons..."
  cp -r "${REPO_DIR}/icons/snap"/*.desktop "${APP_DIR}"
fi

# Install cursors
echo
echo "Installing cursors..."
if [ "$UID" -eq "$ROOT_UID" ]; then
  CURSOR_DEST_DIR="/usr/share/icons"
else
  CURSOR_DEST_DIR="$HOME/.local/share/icons"
fi

if [ -d "$CURSOR_DEST_DIR/${THEME_NAME}-Cursors" ]; then
  rm --recursive --force "$CURSOR_DEST_DIR/${THEME_NAME}-Cursors"
fi

cd "${REPO_DIR}/cursors"
cp --recursive dist "$CURSOR_DEST_DIR/${THEME_NAME}-Cursors"
echo "Installing cursors ... DONE"

# Install Icons
echo
echo "Installing icons..."

cd "${REPO_DIR}/icons"
./install.sh

echo "Installing icons ... DONE"

echo
echo "Done."
