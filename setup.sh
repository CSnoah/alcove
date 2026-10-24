#!/usr/bin/env bash

# ---------------------------------------------------------------------------------
# config: setup program directory 

config_dir="${XDG_CONFIG_HOME:-$HOME/.config}"
alcove_config_file="$config_dir/alcove/alcove.config"
kitty_config_file="$config_dir/kitty/kitty.conf"
shell_name=$(basename "$SHELL")

# create required config directories if they dont exist
mkdir -p "$config_dir/alcove"
mkdir -p "$config_dir/kitty"

# create required config files if they dont exist
touch "$alcove_config_file"
touch "$kitty_config_file"

# get the directory to grab images from for config
while true; do
  if ! read -r -p "Enter image directory: " image_dir; then
    exit 0
  fi

  if [[ "$image_dir" == "exit" ]]; then
    exit 0
  fi

  if [[ -d "$image_dir" ]]; then
    break
  fi

  echo "Directory does not exist. Try again or enter exit."
done

# enable kitty @ - remote controll
if ! grep -q "^allow_remote_control yes" "$kitty_config_file"; then
  echo "allow_remote_control yes" >> "$kitty_config_file"
fi
if ! grep -q "^listen_on" "$kitty_config_file"; then
  echo "listen_on unix:/tmp/mykitty" >> "$kitty_config_file"
fi

# initializing config file
if ! grep -q '^CONF_ALCOVE_PROGM_DIR=' "$alcove_config_file"; then
  echo "CONF_ALCOVE_PROGM_DIR=\"$PWD\"" >> "$alcove_config_file"
fi
if ! grep -q '^CONF_ALCOVE_IMAGE_DIR=' "$alcove_config_file"; then
  echo "CONF_ALCOVE_IMAGE_DIR=\"$image_dir\"" >> "$alcove_config_file"
fi
if ! grep -q '^CONF_ALCOVE_BG_IMAGE_PATH=' "$alcove_config_file"; then
  echo "CONF_ALCOVE_BG_IMAGE_PATH=\"$image_dir\"/kitty-background.png" >> "$alcove_config_file"
fi
if ! grep -q '^CONF_ALCOVE_CURRENT_BG_IMAGE_PATH=' "$alcove_config_file"; then
  echo 'CONF_ALCOVE_CURRENT_BG_IMAGE_PATH=""' >> "$alcove_config_file"
fi
if ! grep -q '^CONF_ALCOVE_DEFAULT_MODE=' "$alcove_config_file"; then
  echo 'CONF_ALCOVE_DEFAULT_MODE=bg' >> "$alcove_config_file"
fi

# notes to user
echo "[NOTE]: alcove path: $PWD"
echo "[NOTE]: If utility path changes update alcove.config: ALCOVE_PROGM_DIR=new-path"
echo "[NOTE]: Config location: $alcove_config_file"
echo "[NOTE]: Default mode: bg"
echo "[NOTE]: Change mode: set-mode <bg|icon|dule>"
echo "[REQUIRED ACTION]: If kitty remote control protocol was not previously enabled, restart terminal!"

# if run setup but config file exists,
# and remove init from .bashrc still grabs PROGM_DIR

# make config file available
source "$alcove_config_file"
# make alcove available
source "$CONF_ALCOVE_PROGM_DIR/init.sh"

# ~ = $HOME
case "$shell_name" in
  bash) 
    rc="$HOME/.bashrc"
    ;;
  zsh)
    rc="$HOME/.zshrc"
    ;;
  ksh)
    rc="$HOME/.kshrc"
    ;;
  fish)
    rc="$HOME/.config/fish/config.fish"
    ;;
  *)
    rc="NA"
    echo "Cannot find appropriate shell"
    ;;
esac

# i don't know why the indentaion is off
if [ "$rc" != "NA" ]; then
# ---------------------------------------------------------------------------------
# heredoc program entry point goes to .<shell-type>rc

echo "SHELL CODE WRAPPER >> .$shell_name.rc"
cat << EOF >> "$rc"

# ----------------------------------------------------------
# alcove utility paraent shell access/startup

source "$CONF_ALCOVE_PROGM_DIR/init.sh"
# ----------------------------------------------------------

EOF

fi

# require user to re-run rc file in current shell context
echo "[REQUIRED ACTION]: source $rc"
# ---------------------------------------------------------------------------------
