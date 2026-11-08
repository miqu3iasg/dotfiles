#!/usr/bin/env bash

FIXED_GAP="${FIXED_GAP:-10}"
STATE_FILE="${XDG_RUNTIME_DIR:-/tmp}/i3-gaps-on"

if [[ -f "$STATE_FILE" ]]; then
    i3-msg "gaps inner all set 0, gaps outer all set 0" >/dev/null
    rm -f "$STATE_FILE"
else
    i3-msg "gaps inner all set $FIXED_GAP, gaps outer all set $FIXED_GAP" >/dev/null
    touch "$STATE_FILE"
fi
