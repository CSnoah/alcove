# alcove -m <mode> <path>

handle_default() {
  # let user enter raw path or just filename in specified directory
  local file_path="$CONF_ALCOVE_KITTY_IMAGE_DIR/$1"
  if [[ ! -f "$file_path" ]]; then
    if [[ -f "$1" ]]; then
      file_path=$1
    else
      echo "info: [ Enter a valid filepath ]"
    fi
  fi

  # no parameter 
  if [[ "$ALCOVE_PARAM_COUNT" -eq 1 && -f "$file_path" ]]; then
    # icon
    if [[ "$ALCOVE_MODE" == "icon" || "$ALCOVE_MODE" == "dule" ]]; then
      # reset
      kitty @ set-window-logo none
      kitty @ set-window-logo "$file_path"
    fi

    # bg
    if [[ "$ALCOVE_MODE" == "bg" || "$ALCOVE_MODE" == "dule" ]]; then
      # reset
      kitty @ set-background-image none
      # set current image url in config file
      sed -i '' "s|^CONF_ALCOVE_CURRENT_BG_IMAGE_PATH=.*|CONF_ALCOVE_CURRENT_BG_IMAGE_PATH=$file_path|" "$ALCOVE_CONFIG_FILE"

      if [[ ! -f "$CONF_ALCOVE_BG_IMAGE_PATH" ]]; then
        echo "[ERROR]: Config var CONF_ALCOVE_BG_IMAGE_PATH incorrecly set."
      fi

      # create concatinated image
      # file write lags so just using parameter 
      magick -size 1920x1080 xc:transparent \
        "$file_path" \
        -geometry 700x600+0+0 \
        -gravity southeast \
        -composite \
        $CONF_ALCOVE_BG_IMAGE_PATH
      # set terminal background image
      kitty @ set-background-image --layout=scaled "$CONF_ALCOVE_BG_IMAGE_PATH"
    fi
  fi
}

handle_flags() {
  # parse flags
  while getopts "hm:" opts; do
    case "$opts" in
      h)
        echo "----------------------------------------------------"
        echo "Basic Usage: alcove {<filepath>|on|off|}"
        echo "----------------------------------------------------"
        echo "----------------------------------------------------"
        echo "modes"
        echo "                   Alcove utilizes the kitty remote control protocol"
        echo "                   This proticol offers two ways to display a background image"
        echo "                   mode=gb => uses kitty @ set-background-image"
        echo "                   mode=icon => uses kitty @ set-window-logo"
        echo "                   mode=dule => targets both"
        echo "----------------------------------------------------"
        echo "----------------------------------------------------"
        echo "flags"
        echo "m <mode>           Designate a mode {bg|icon|dule}"
        echo "                   Example: alcove -m icon <path>"
        echo "h                  Bring up the help menu"
        echo "----------------------------------------------------"
        echo "----------------------------------------------------"
        echo "Commands:"
        echo "alcove <path>      Set the background/icon to the imagepath"
        echo "on                 Turn {bg&&icon} image on"
        echo "off                Turn {bg&&icon} image off"
        echo "config             Shows all settings in config file"
        echo "set-mode <mode>    Allows you to set the default mode in the config file"
        echo "set-"
        echo "..."
        echo "----------------------------------------------------"
        ;;
      m)
        # set mode
        ALCOVE_MODE="$OPTARG"
        # prune params
        shift $((OPTIND - 1))
        ALCOVE_PARAMS=("$@")
        ALCOVE_PARAM_COUNT="$#"
    esac
  done 
}

handle_on() {
  if [[ "$ALCOVE_MODE" == "bg" ]]; then
    kitty @ set-background-image --layout=scaled "$CONF_ALCOVE_BG_IMAGE_PATH"
  elif [[ "$ALCOVE_MODE" == "icon" ]]; then
    kitty @ set-window-logo "$CONF_ALCOVE_BG_IMAGE_PATH"
  else
    # dule
    kitty @ set-background-image --layout=scaled "$CONF_ALCOVE_BG_IMAGE_PATH"
    kitty @ set-window-logo "$CONF_ALCOVE_BG_IMAGE_PATH"
  fi
}

handle_off() {
  if [[ "$ALCOVE_MODE" == "bg" ]]; then
    kitty @ set-background-image none
  elif [[ "$ALCOVE_MODE" == "icon" ]]; then
    kitty @ set-window-logo none
  else
    # dule
    kitty @ set-window-logo none
    kitty @ set-background-image none
  fi
}

handle_print_config() {
  echo "CONF_ALCOVE_CURRENT_BG_IMAGE_PATH: $CONF_ALCOVE_CURRENT_BG_IMAGE_PATH"
  echo "CONF_ALCOVE_BG_IMAGE_PATH: $CONF_ALCOVE_BG_IMAGE_PATH"
  echo "CONF_ALCOVE_KITTY_IMAGE_DIR: $CONF_ALCOVE_KITTY_IMAGE_DIR"
  echo "CONF_ALCOVE_PROGM_DIR: $CONF_ALCOVE_PROGM_DIR"
  echo "CONF_ALCOVE_DEFAULT_MODE: $CONF_ALCOVE_DEFAULT_MODE"
}

handle_update() {
  current="$(ls /tmp/mykitty-* | head -n 1)"
  echo "[INFO]: new socket: $current"
  echo "[INFO]: old socket: $KITTY_LISTEN_ON"
  if [[ -f "unix:$current" ]]; then
    export KITTY_LISTEN_ON="unix:$current"
    echo "updated socket: $KITTY_LISTEN_ON"
  else
    echo "[INFO]: cant find a new socket"
  fi

  # current="$(ls /tmp/mykitty-* | head -n 1)"
  # echo "export KITTY_LISTEN_ON=\"unix:$current\""
  
  # local socket
  #
  # for socket in /tmp/mykitty-*(N); do
  #   [[ -S "$socket" ]] || continue
  #
  #   if kitty @ --to "unix:$socket" ls >/dev/null 2>&1; then
  #     export KITTY_LISTEN_ON="unix:$socket"
  #     echo "Connected to: $KITTY_LISTEN_ON"
  #     return 0
  #   fi
  # done
  #
  # echo "No working Kitty socket found." >&2
  # return 1
}

handle_set_mode() {
  ALCOVE_MODE="$2"
  if [[ "$ALCOVE_MODE" == "bg" || "$ALCOVE_MODE" == "icon" || "$ALCOVE_MODE" == "dule" ]]; then
    sed -i '' "s|^CONF_ALCOVE_DEFAULT_MODE=.*|CONF_ALCOVE_DEFAULT_MODE=$ALCOVE_MODE|" "$ALCOVE_CONFIG_FILE"
    echo "info: [ valid mode set ]"
    source "$ALCOVE_CONFIG_FILE"
    echo "CONF_ALCOVE_DEFAULT_MODE: $CONF_ALCOVE_DEFAULT_MODE"
  else
    echo "enter a valid mode: [ bg, icon, dule ]"
  fi
}

handle_bg_compose() {
  file_path="$CONF_ALCOVE_KITTY_IMAGE_DIR/$1"
  if [[ "$#" -eq 1 && -f "$file_path" ]]; then
    # set current image url in config file
    sed -i '' "s|^CONF_ALCOVE_CURRENT_BG_IMAGE_PATH=.*|CONF_ALCOVE_CURRENT_BG_IMAGE_PATH=$file_path|" "$ALCOVE_CONFIG_FILE"
    # create concatinated image
    # file write lags so just using parameter 
    magick -size 1920x1080 xc:transparent \
      "$file_path" \
      -geometry 900x800+0+0 \
      -gravity southeast \
      -composite \
      $CONF_ALCOVE_BG_IMAGE_PATH
    # set terminal background image
    kitty @ set-background-image --layout=scaled "$CONF_ALCOVE_BG_IMAGE_PATH"
  fi
}

handle_bg_create() {
  magick -size 1920x1080 xc:transparent \
    "$CONF_ALCOVE_CURRENT_BG_IMAGE_PATH" \
    -geometry 700x600+0+0 \
    -gravity southeast \
    -composite \
    $CONF_ALCOVE_BG_IMAGE_PATH
  kitty @ set-background-image --layout=scaled "$CONF_ALCOVE_BG_IMAGE_PATH"
}

handle_set_size() {
  # error checking 
  local param_count=$(($# - 1))
  if [[ "$ALCOVE_MODE" == 'dule' && $param_count -ne 3 ]]; then
    echo "[ERROR]: must supply three parameters."
    echo "[Note]: alcove set_size <leng> <width> <size>"
    return 1
  fi
  if [[ "$ALCOVE_MODE" == 'bg' && $param_count -ne 2 ]]; then
    echo "[ERROR]: must supply two parameters."
    echo "[Note]: alcove set_size <leng> <width>"
    return 1
  fi
  if [[ "$ALCOVE_MODE" == 'icon' && $param_count -ne 1 ]]; then
    echo "[ERROR]: must supply 1 parameter."
    echo "[Note]: alcove set_size <size>"
    return 1
  fi

  # handle condition mode=bg
  if [[ "$ALCOVE_MODE" == 'bg' || "$ALCOVE_MODE" == 'dule' ]]; then
    magick -size 1920x1080 xc:transparent \
      "$CONF_ALCOVE_CURRENT_BG_IMAGE_PATH" \
      -geometry "$2"x"$3"+0+0 \
      -gravity southeast \
      -composite \
      "$CONF_ALCOVE_BG_IMAGE_PATH"
    kitty @ set-background-image --layout=scaled "$CONF_ALCOVE_BG_IMAGE_PATH"
  fi
  # handle condition mode=icon
  if [[ "$ALCOVE_MODE" == 'icon' || "$ALCOVE_MODE" == "dule" ]]; then
    local size="$2"
    if [[ -f "$KITTY_CONFIG_FILE" ]]; then
      if grep -q '^window_logo_scale ' "$KITTY_CONFIG_FILE"; then
        sed -i '' "s|^window_logo_scale .*|window_logo_scale $size|" "$KITTY_CONFIG_FILE"
      else
        echo "window_logo_scale $size" >> "$KITTY_CONFIG_FILE"
      fi
    else
      echo "[ERROR]: kitty config does not exist"
    fi
  fi
}
