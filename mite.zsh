#!/bin/zsh

# CURRENT_IMAGE_PATH - a convenient variable that allows operations to occur without the user constanly having to provide the image path
# KITTY_IMAGE_PATH - the location that the image is stored
source "$(dirname $0)/.config.zsh"

image_path="$1"
if [[ "$#" -eq 1 && -f "$1" ]]; then
  # set image url
  sed -i '' "s|^CURRENT_IMAGE_PATH=.*|CURRENT_IMAGE_PATH=$image_path|" "$(dirname $0)/.config.zsh"
  # create concatinated image
  # file write lags so just using parameter 
  magick -size 1920x1080 xc:transparent \
    "$image_path" \
    -geometry 700x600+0+0 \
    -gravity southeast \
    -composite \
    $KITTY_IMAGE_PATH
  # set terminal background image
  kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
fi

case "$1" in
    on)
        kitty @ set-background-image --layout=scaled "$KITTY_IMAGE_PATH"
        ;;
    off)
        kitty @ set-background-image none
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
      sed -i '' "s|^CURRENT_IMAGE_PATH=.*|CURRENT_IMAGE_PATH=$2|" "$(dirname $0)/.config.zsh"
      ;;
    set-bg-path)
      sed -i '' "s|^KITTY_IMAGE_PATH=.*|KITTY_IMAGE_PATH=$2|" "$(dirname $0)/.config.zsh"
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
    update)
      # current="$(ls /tmp/mykitty-* | head -n 1)"
      # echo "new socket: $current"
      # echo "old socket: $KITTY_LISTEN_ON"
      # export KITTY_LISTEN_ON="unix:$current"
      # echo "updated socket: $KITTY_LISTEN_ON"

      current="$(ls /tmp/mykitty-* | head -n 1)"
      echo "export KITTY_LISTEN_ON=\"unix:$current\""
      ;;
    *)
      echo "Usage: mite {on|off}"
      ;;
esac
