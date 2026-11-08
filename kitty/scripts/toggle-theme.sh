#!/usr/bin/env bash

KITTY="$HOME/.config/kitty"
TMUX_DIR="$HOME/.config/tmux"

STARSHIP="$HOME/.config/starship.toml"

if [[ "$(readlink -f "$KITTY/theme.conf")" == *mono-light.conf ]]; then
    THEME=mono
    FONT=normal
    PALETTE=mono
else
    THEME=mono-light
    FONT=bold
    PALETTE=mono_light
fi

sed -i --follow-symlinks "s/^palette = .*/palette = \"$PALETTE\"/" "$STARSHIP"

ln -sfn "themes/$THEME.conf" "$TMUX_DIR/theme.conf"
tmux source-file -q "$TMUX_DIR/theme.conf" 2>/dev/null

ln -sfn "themes/$THEME.conf" "$KITTY/theme.conf"
ln -sfn "fonts/$FONT.conf" "$KITTY/font.conf"
kill -SIGUSR1 $(pgrep -x kitty)
