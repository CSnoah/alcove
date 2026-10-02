#!/usr/bin/env bash

# config file
# source "$(dirname $0)/.config.zsh"
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/mite"
config_file="$config_dir/mite.config"
source "$config_file"

mite() {
  source $MITE_PROGM_DIR/mite.sh "$@"
}

# mitigate autocomplete
imgs_autoc() {
  # local db_aliases="$($PROGM_DIR/src/autocomplete.py)"
  local image_files="$(ls $KITTY_IMAGE_DIR)"
  local cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${image_files}" -- "$cur") )
}
complete -F imgs_autoc mite
