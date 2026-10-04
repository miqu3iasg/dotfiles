#!/bin/sh
dir="$HOME/media/screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

# Just clipboard (don't save in the folder)
if [ "$1" = "clip" ]; then
  tmp=$(mktemp --suffix=.png)
  maim -s -u "$tmp" \
    && xclip -selection clipboard -t image/png -i "$tmp" \
    && notify-send -i "$tmp" "Screenshot copied" "Clipboard only"
  exit
fi

# Save and copy
case "$1" in
  area)            maim -s -u "$file" ;;
  window|janela)   maim -u -i "$(xdotool getactivewindow)" "$file" ;;
  *)               maim -u "$file" ;;
esac && {
  xclip -selection clipboard -t image/png -i "$file"
  notify-send -i "$file" "Screenshot saved" "Copied to clipboard"
}
