#!/usr/bin/env bash

source "$(dirname $0)/.config.zsh"

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
