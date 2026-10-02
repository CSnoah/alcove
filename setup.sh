#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
# config: setup program directory 

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/alcove"
config_file="$config_dir/alcove.config"

mkdir -p "$config_dir"

if [[ ! -f "$config_file" ]]; then
  touch "$config_file"
  echo "ALCOVE_PROGM_DIR=\"$PWD\"" >> "$config_file"
  echo "[NOTE]: alcove path: $PWD"
  echo "[NOTE]: If utility path changes update alcove.config: ALCOVE_PROGM_DIR=new-path"
  echo "[NOTE]: Config location: $config_file"
fi

# if run setup but config file exists,
# and remove init from .bashrc still grabs PROGM_DIR
source "$config_file"
# ---------------------------------------------------------------------------------
