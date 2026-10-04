#!/usr/bin/env bash

# config file
# source "$(dirname $0)/.config.zsh"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alcove"
config_file="$config_dir/alcove.config"
source "$config_file"

alcove() {
  source $ALCOVE_PROGM_DIR/alcove.sh "$@"
}

# autocomplete
imgs_autoc() {
  local image_files="$(ls $KITTY_IMAGE_DIR)"
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${image_files}" -- "$cur") )
}
complete -F imgs_autoc alcove 
