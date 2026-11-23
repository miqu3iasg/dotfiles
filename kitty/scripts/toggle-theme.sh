#!/usr/bin/env bash

KITTY="$HOME/.config/kitty"
TMUX_DIR="$HOME/.config/tmux"
STARSHIP="$HOME/.config/starship.toml"

if [[ "$(readlink -f "$KITTY/theme.conf")" == *solarized-light.conf ]]; then
    THEME=mono
    FONT=normal
    PALETTE=mono
else
    THEME=solarized-light
    FONT=bold
    PALETTE=mono_light
fi

sed -i --follow-symlinks "s/^palette = .*/palette = \"$PALETTE\"/" "$STARSHIP"

ln -sfn "themes/$THEME.conf" "$KITTY/theme.conf"
ln -sfn "fonts/$FONT.conf" "$KITTY/font.conf"
pkill -USR1 -x kitty
sleep 0.3

ln -sfn "themes/$THEME.conf" "$TMUX_DIR/theme.conf"
for opt in status-style status-left-style status-right-style \
    message-style message-command-style mode-style \
    pane-border-style pane-active-border-style \
    display-panes-colour display-panes-active-colour \
    window-status-style window-status-current-style \
    window-status-activity-style window-status-bell-style \
    window-status-last-style window-status-separator \
    clock-mode-colour; do
    tmux set -gu "$opt" 2>/dev/null
done
tmux source-file -q "$TMUX_DIR/theme.conf" 2>/dev/null
for c in $(tmux list-clients -F '#{client_name}' 2>/dev/null); do
    tmux refresh-client -t "$c" 2>/dev/null
done
