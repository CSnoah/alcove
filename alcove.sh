#!/usr/bin/env bash

# CURRENT_IMAGE_PATH - a convenient variable that allows operations to occur without the user constanly having to provide the image path
# KITTY_IMAGE_PATH - the location that the image is stored
# source "$(dirname $0)/.config.zsh"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alcove"
config_file="$config_dir/alcove.config"
source "$config_file"

mode="$DEFAULT_MODE"
param_count="$#"

# parse flags
while getopts "hm:" opts; do
  case "$opts" in
    h)
      echo "----------------------------------------------------"
      echo "Basic Usage: alcove {<filepath>|on|off|}"
      echo "----------------------------------------------------"
      # echo "\n"
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
      # echo "\n"
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
      mode="$OPTARG"
  esac
done
shift $((OPTIND - 1))
param_count="$#"

# valid_commands=("on" "off" "compose" "create" "set-mode" "set-size", "update", "config")
# valid_flags=("-m" "-h")

file_path="$KITTY_IMAGE_DIR/$1"
# let user enter raw path or just filename in specified directory()
if [[ ! -f "$file_path" ]]; then
  if [[ -f "$1" ]]; then
    file_path=$1
    # echo "info: [ file is valid ]"
  else
      # echo "info: [ Enter a valid filepath ]"
  fi
else
  # echo "info: [ filepath is valid ]"
fi

# no parameter 
if [[ "$param_count" -eq 1 && -f "$file_path" ]]; then
  # icon
  if [[ "$mode" == "icon" || "$mode" == "dule" ]]; then
    # reset
    kitty @ set-window-logo none
    kitty @ set-window-logo "$file_path"
    echo "info: [ set icon ]"
  fi

  # bg
  if [[ "$mode" == "bg" || "$mode" == "dule" ]]; then
    # reset
    kitty @ set-background-image none
    # set current image url in config file
    sed -i '' "s|^CURRENT_IMAGE_PATH=.*|CURRENT_IMAGE_PATH=$file_path|" "$config_file"
    # create concatinated image
    # file write lags so just using parameter 
    magick -size 1920x1080 xc:transparent \
      "$file_path" \
      -geometry 900x800+0+0 \
      -gravity southeast \
      -composite \
      $KITTY_IMAGE_PATH
    # set terminal background image
    kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
    echo "info: [ set bg ]"
  fi
fi

case "$1" in
    on)
      kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
      kitty @ set-window-logo "$KITTY_IMAGE_PATH"
      ;;
    off)
      kitty @ set-background-image none
      kitty @ set-window-logo none
      ;;
    compose)
      file_path="$KITTY_IMAGE_DIR/$1"
      if [[ "$#" -eq 1 && -f "$file_path" ]]; then
        # set current image url in config file
        sed -i '' "s|^CURRENT_IMAGE_PATH=.*|CURRENT_IMAGE_PATH=$file_path|" "$config_file"
        # create concatinated image
        # file write lags so just using parameter 
        magick -size 1920x1080 xc:transparent \
          "$file_path" \
          -geometry 900x800+0+0 \
          -gravity southeast \
          -composite \
          $KITTY_IMAGE_PATH
        # set terminal background image
        kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
      fi
      ;;
    create)
      magick -size 1920x1080 xc:transparent \
        "$CURRENT_IMAGE_PATH" \
        -geometry 700x600+0+0 \
        -gravity southeast \
        -composite \
        $KITTY_IMAGE_PATH
      kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
      ;;
    set-image)
      sed -i '' "s|^CURRENT_IMAGE_PATH=.*|CURRENT_IMAGE_PATH=$2|" "$config_file"
      ;;
    set-bg-path)
      sed -i '' "s|^KITTY_IMAGE_PATH=.*|KITTY_IMAGE_PATH=$2|" "$config_file"
      ;;
    set-size)
      magick -size 1920x1080 xc:transparent \
        "$CURRENT_IMAGE_PATH" \
        -geometry "$2"x"$3"+0+0 \
        -gravity southeast \
        -composite \
        "$KITTY_IMAGE_PATH"
      kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
      ;;
    set-mode)
      mode="$2"
      if [[ "$mode" == "bg" || "$mode" == "icon" || "$mode" == "dule" ]]; then
        sed -i '' "s|^DEFAULT_MODE=.*|DEFAULT_MODE=$mode|" "$config_file"
        echo "info: [ valid mode set ]"
        source "$config_file"
        echo "DEFAULT_MODE: $DEFAULT_MODE"
      else
        echo "enter a valid mode: [ bg, icon, dule ]"
      fi
      ;;
    update)
      current="$(ls /tmp/mykitty-* | head -n 1)"
      echo "new socket: $current"
      echo "old socket: $KITTY_LISTEN_ON"
      export KITTY_LISTEN_ON="unix:$current"
      echo "updated socket: $KITTY_LISTEN_ON"
      # current="$(ls /tmp/mykitty-* | head -n 1)"
      # echo "export KITTY_LISTEN_ON=\"unix:$current\""
      ;;
    config)
      echo "CURRENT_IMAGE_PATH: $CURRENT_IMAGE_PATH"
      echo "KITTY_IMAGE_PATH: $KITTY_IMAGE_PATH"
      echo "KITTY_IMAGE_DIR: $KITTY_IMAGE_DIR"
      echo "ALCOVE_PROGM_DIR: $ALCOVE_PROGM_DIR"
      echo "DEFAULT_MODE: $DEFAULT_MODE"
      ;;
    *)
      # echo "did it"
      ;;
esac
