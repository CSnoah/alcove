
image_url="$HOME/Downloads/selena-gomez.png"
image_location="$HOME/Downloads/kitty-background.png"

# too big and wrong locaiton
# magick -size 1920x1080 xc:none \
#   "$image_url" \
#   -resize 400x600 \
#   -gravity southeast \
#   -composite \
#   ~/Downloads/kitty-background.png

# small image red
# magick \
#   -size 1920x1080 xc:transparent \
#   \( "$image_url" -resize 700x600! -bordercolor red -border 30 \) \
#   -gravity southeast \
#   -composite \
#   ~/Downloads/kitty-background.png

echo "1=[$1]"
echo "2=[$2]"
echo "3=[$3]"

case "$1" in
    on)
        kitty @ set-background-image --layout=scaled "$image_location"
        ;;
    off)
        kitty @ set-background-image none
        ;;
    create)
      magick -size 1920x1080 xc:transparent \
        "$image_url" \
        -geometry 700x600+0+0 \
        -gravity southeast \
        -composite \
        ~/Downloads/kitty-background.png
      ;;
    *)
        echo "Usage: kitty-bg {on|off}"
        ;;
esac
