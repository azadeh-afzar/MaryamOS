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

# Check command avalibility
function has_command() {
  command -v $1 > /dev/null
}

operation_canceled() {
  clear
  prompt  --info "\n Operation canceled by user, Bye!"
  exit 1
}

usage() {
  printf "%s\n" "Usage: $0 [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-d, --dest DIR" "Specify theme destination directory (Default: ${DEST_DIR})"
  printf "  %-25s%s\n" "-n, --name NAME" "Specify theme name (Default: ${THEME_NAME})"
  printf "  %-25s%s\n" "-o, --opacity VARIANTS" "Specify theme opacity variant(s) [standard|solid] (Default: All variants)"
  printf "  %-25s%s\n" "-c, --color VARIANTS" "Specify theme color variant(s) [light|dark] (Default: All variants)"
  printf "  %-25s%s\n" "-a, --alt VARIANTS" "Specify theme titilebutton variant(s) [standard|alt] (Default: All variants)"
  printf "  %-25s%s\n" "-i, --icon VARIANTS" "Specify activities icon variant(s) for gnome-shell [standard|normal|gnome|ubuntu|arch|manjaro|fedora|debian|void] (Default: standard variant)"
  printf "  %-25s%s\n" "-s, --size VARIANTS" "Run a dialg to change the nautilus sidebar width size (Default: 200px)"
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

  prompt --info "Installing '${THEME_DIR}'..."

  mkdir --parents                                                                                          "${THEME_DIR}"
  cp --update --recursive "${REPO_DIR}/LICENSE"                                                            "${THEME_DIR}"

  echo "[Desktop Entry]" >>                                                                                "${THEME_DIR}/index.theme"
  echo "Type=X-GNOME-Metatheme" >>                                                                         "${THEME_DIR}/index.theme"
  echo "Name=${name}${color}${opacity}" >>                                                                 "${THEME_DIR}/index.theme"
  echo "Comment=An Stylish Gtk+ theme based on Elegant Design" >>                                          "${THEME_DIR}/index.theme"
  echo "Encoding=UTF-8" >>                                                                                 "${THEME_DIR}/index.theme"
  echo "" >>                                                                                               "${THEME_DIR}/index.theme"
  echo "[X-GNOME-Metatheme]" >>                                                                            "${THEME_DIR}/index.theme"
  echo "GtkTheme=${name}${color}${opacity}" >>                                                             "${THEME_DIR}/index.theme"
  echo "MetacityTheme=${name}${color}${opacity}" >>                                                        "${THEME_DIR}/index.theme"
  echo "IconTheme=McMojave-circle" >>                                                                      "${THEME_DIR}/index.theme"
  echo "CursorTheme=McMojave-circle" >>                                                                    "${THEME_DIR}/index.theme"
  echo "ButtonLayout=close,minimize,maximize:menu" >>                                                      "${THEME_DIR}/index.theme"

  # install Gnome shell theme.
  # set right icon for activity panel
  local var="\$icon-logo: '${icon}';";
  sed --in-place "1s/.*/${var}/"  "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}.scss"
  
  # generate css files.
  parse_sass
  
  # copy css files.
  mkdir --parents                                                                                          "${THEME_DIR}/gnome-shell"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/source-assets"/*                                  "${THEME_DIR}/gnome-shell"
  cp --update --recursive "${SRC_DIR}/main/gnome-shell/gnome-shell${color}${opacity}.css"                  "${THEME_DIR}/gnome-shell/gnome-shell.css"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/common-assets"                                    "${THEME_DIR}/gnome-shell/assets"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/assets${color}"/*.svg                             "${THEME_DIR}/gnome-shell/assets"
  cp --update --recursive "${SRC_DIR}/assets/gnome-shell/assets${color}/activities/activities${icon}"*.svg "${THEME_DIR}/gnome-shell/assets/"

  # install gtk3 theme.
  mkdir --parents                                                                                          "${THEME_DIR}/gtk-3.0"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/common-assets/assets"                                 "${THEME_DIR}/gtk-3.0"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/common-assets/sidebar-assets"/*.png                   "${THEME_DIR}/gtk-3.0/assets"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/windows-assets/titlebutton${alt}"                     "${THEME_DIR}/gtk-3.0/windows-assets"
  cp --update --recursive "${SRC_DIR}/assets/gtk-3.0/thumbnail${color}.png"                                "${THEME_DIR}/gtk-3.0/thumbnail.png"
  cp --update --recursive "${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}.css"                                 "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  if [[ ${color} == '-light' ]]; then
    cp --update --recursive "${SRC_DIR}/main/gtk-3.0/gtk-light${opacity}.css"                              "${THEME_DIR}/gtk-3.0/gtk.css"
  else
    cp --update --recursive "${SRC_DIR}/main/gtk-3.0/gtk-dark${opacity}.css"                               "${THEME_DIR}/gtk-3.0/gtk.css"
  fi

  glib-compile-resources --sourcedir="${THEME_DIR}/gtk-3.0" --target="${THEME_DIR}/gtk-3.0/gtk.gresource" "${SRC_DIR}/main/gtk-3.0/gtk.gresource.xml"
  rm --recursive --force                                                                                  "${THEME_DIR}/gtk-3.0/{assets,windows-assets,gtk.css,gtk-dark.css}"
  echo '@import url("resource:///org/gnome/theme/gtk.css");' >>                                           "${THEME_DIR}/gtk-3.0/gtk.css"
  echo '@import url("resource:///org/gnome/theme/gtk-dark.css");' >>                                      "${THEME_DIR}/gtk-3.0/gtk-dark.css"

  # install plank dock theme.
  mkdir --parents                                                                                         "${THEME_DIR}/plank"
  cp --update --recursive "${SRC_DIR}/other/plank/theme${color}"/*.theme                                  "${THEME_DIR}/plank"

  mkdir --parents                                                                                         "${PLANK_DIR}/${2}${3}"
  cp --update --recursive "${SRC_DIR}/other/plank/theme${color}"/*.theme                                  "${PLANK_DIR}/${2}${3}"
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
  prompt --info "Installing ${2}${3}${4} gdm theme..."

  if [[ -f "$GS_THEME_FILE" ]] && command -v glib-compile-resources >/dev/null ; then
    prompt --info "Installing '$GS_THEME_FILE'..."
    cp --archive --no-clobber "$GS_THEME_FILE" "$GS_THEME_FILE.bak"
    glib-compile-resources \
      --sourcedir="$GDM_THEME_DIR/gnome-shell" \
      --target="$GS_THEME_FILE" \
      "${SRC_DIR}/main/gnome-shell/gnome-shell-theme.gresource.xml"
  fi

  if [[ -f "$UBUNTU_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt --info "Installing '$UBUNTU_THEME_FILE'..."
    cp --archive --no-clobber "$UBUNTU_THEME_FILE" "$UBUNTU_THEME_FILE.bak"
    cp --archive --force "$GDM_THEME_DIR/gnome-shell/gnome-shell.css" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt --info "Installing '$UBUNTU_NEW_THEME_FILE'..."
    cp --archive --no-clobber "$UBUNTU_NEW_THEME_FILE" "$UBUNTU_NEW_THEME_FILE.bak"
    cp --archive --force "$GDM_THEME_DIR"/gnome-shell/* "$SHELL_THEME_FOLDER"
  fi

  if [[ -f "$ETC_THEME_FILE" && -f "$GS_THEME_FILE.bak" ]]; then
    prompt --info "Installing Ubuntu gnome-shell theme..."
    cp --archive --no-clobber "$ETC_THEME_FILE" "$ETC_THEME_FILE.bak"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm --recursive --force $SHELL_THEME_FOLDER/$THEME_NAME
    cp --update --recursive "$GDM_THEME_DIR/gnome-shell" "$SHELL_THEME_FOLDER/$THEME_NAME"
    cd "$ETC_THEME_FOLDER"
    ln --symbolic "$SHELL_THEME_FOLDER/$THEME_NAME/gnome-shell.css" gdm3.css
  fi
}

revert_gdm() {
  if [[ -f "$GS_THEME_FILE.bak" ]]; then
    prompt --warning "reverting '$GS_THEME_FILE'..."
    rm --recursive --force "$GS_THEME_FILE"
    mv "$GS_THEME_FILE.bak" "$GS_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_THEME_FILE.bak" ]]; then
    prompt --warning "reverting '$UBUNTU_THEME_FILE'..."
    rm --recursive --force "$UBUNTU_THEME_FILE"
    mv "$UBUNTU_THEME_FILE.bak" "$UBUNTU_THEME_FILE"
  fi

  if [[ -f "$UBUNTU_NEW_THEME_FILE.bak" ]]; then
    prompt --warning "reverting '$UBUNTU_NEW_THEME_FILE'..."
    rm --recursive --force "$UBUNTU_NEW_THEME_FILE" "$SHELL_THEME_FOLDER"/{assets,no-events.svg,process-working.svg,no-notifications.svg}
    mv "$UBUNTU_NEW_THEME_FILE.bak" "$UBUNTU_NEW_THEME_FILE"
  fi

  if [[ -f "$ETC_THEME_FILE.bak" ]]; then
    prompt --warning "reverting Ubuntu gnome-shell theme..."
    rm --recursive --force "$ETC_THEME_FILE"
    mv "$ETC_THEME_FILE.bak" "$ETC_THEME_FILE"
    [[ -d $SHELL_THEME_FOLDER/$THEME_NAME ]] && rm --recursive --force $SHELL_THEME_FOLDER/$THEME_NAME
  fi
}


install_dialog() {
  if [ ! "$(which dialog 2> /dev/null)" ]; then
    prompt -w "\n 'dialog' needs to be installed for this shell"
    if has_command zypper; then
      sudo zypper in dialog
    elif has_command apt-get; then
      sudo apt-get install dialog
    elif has_command dnf; then
      sudo dnf install -y dialog
    elif has_command yum; then
      sudo yum install dialog
    elif has_command pacman; then
      sudo pacman -S --noconfirm dialog
    fi
  fi
}

run_dialog() {
  if [[ -x /usr/bin/dialog ]]; then
    tui=$(dialog --backtitle "${THEME_NAME} gtk theme installer" \
    --radiolist "Choose your nautilus sidebar size (default is 200px width): " 15 40 5 \
      1 "200px" on  \
      2 "220px" off \
      3 "240px" off  \
      4 "260px" off  \
      5 "280px" off --output-fd 1 )
      case "$tui" in
        1) sidebar_size="200px" ;;
        2) sidebar_size="220px" ;;
        3) sidebar_size="240px" ;;
        4) sidebar_size="260px" ;;
        5) sidebar_size="280px" ;;
        *) operation_canceled ;;
     esac
  fi
}

change_size() {
  cd "${SRC_DIR}/sass/gtk"
  cp --archive --no-clobber _applications.scss _applications.scss.bak
  sed --in-place "s/200px/$sidebar_size/g" _applications.scss
  prompt --warning "Change nautilus sidebar size ..."
}

restore_file() {
  cd ${SRC_DIR}/sass/gtk
  [[ -f _applications.scss.bak ]] && rm --recursive --force _applications.scss
  mv _applications.scss.bak _applications.scss
  prompt --warning "Restore scss file ..."
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
    -g|--gdm)
      gdm='true'
      shift 1
      ;;
    -s|--size)
      size='true'
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
            prompt --error "ERROR: Unrecognized opacity variant '$1'."
            prompt --info "Try '$0 --help' for more information."
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

# Change sidebar width if specified by user.
if [[ "${size:-}" == 'true' ]]; then
  install_dialog && run_dialog

  if [[ "$sidebar_size" != '200px' ]]; then
    change_size
  fi
fi

# install theme
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

# Revert size change.
if [[ -f "${SRC_DIR}"/sass/gtk/_applications.scss.bak ]]; then
  restore_file && parse_sass
fi

# copy snap desktop files.
if [[ "${snap:-}" == 'true' ]]; then
  echo
  prompt --info "Installing custome snap pakage icons..."
  cp --recursive "${REPO_DIR}/icons/snap"/*.desktop "${APP_DIR}"
  prompt --success "Installing custome snap pakage icons ... DONE"
fi

# Install cursors
echo
prompt --info "Installing cursors..."
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
prompt --success "Installing cursors ... DONE"

# Install Icons
echo
prompt --info "Installing icons..."

cd "${REPO_DIR}/icons"
./install.sh

prompt --success "Installing icons ... DONE"

echo
prompt --success "Done."
