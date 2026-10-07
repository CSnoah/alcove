#!/usr/bin/env bash

# CURRENT_IMAGE_PATH - a convenient variable that allows operations to occur without the user constanly having to provide the image path
# KITTY_IMAGE_PATH - the location that the image is stored
# source "$(dirname $0)/.config.zsh"

# config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alcove"
# config_file="$config_dir/alcove.config"
ALCOVE_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/alcove"
ALCOVE_CONFIG_FILE="$ALCOVE_CONFIG_DIR/alcove.config"
ALCOVE_MODE="$CONF_ALCOVE_DEFAULT_MODE"
ALCOVE_PARAM_COUNT="$#"
ALCOVE_PARAMS=("$@")
KITTY_CONFIG_FILE="$HOME/.config/kitty/kitty.conf"

source "$ALCOVE_CONFIG_FILE"
source "$(dirname "$0")/handle-commands.sh"

# parse flags
#################
handle_flags "${ALCOVE_PARAMS[@]}"
# handle_flags "$@"
# shift $((OPTIND - 1))
# shift $((param_count - 1))
# param_count="$#"
#################

# handle primary command
#################
# handle_default "$@"
# handle_default "${params[@]}"
################

case "$1" in
    on)
      handle_on 
      ;;
    off)
      handle_off
      ;;
    bg-compose)
      handle_bg_compose "${ALCOVE_PARAMS[@]}"
      ;;
    bg-create)
      handle_bg_create
      ;;
    bg-set-image)
      sed -i '' "s|^CONF_ALCOVE_CURRENT_IMAGE_PATH=.*|CONF_ALCOVE_CURRENT_IMAGE_PATH=$2|" "$ALCOVE_CONFIG_FILE"
      ;;
    bg-set-path)
      sed -i '' "s|^CONF_ALCOVE_KITTY_IMAGE_PATH=.*|CONF_ALCOVE_KITTY_IMAGE_PATH=$2|" "$ALCOVE_CONFIG_FILE"
      ;;
    set-size)
      handle_set_size "${ALCOVE_PARAMS[@]}"
      ;;
    set-mode)
      handle_set_mode "${ALCOVE_PARAMS[@]}"
      ;;
    update)
      handle_update
      ;;
    config)
      handle_print_config 
      ;;
    *)
      handle_default "${ALCOVE_PARAMS[@]}"
      ;;
esac
