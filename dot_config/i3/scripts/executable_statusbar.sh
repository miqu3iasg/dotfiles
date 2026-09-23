#!/bin/bash

i3status | while IFS= read -r line; do
    pomo=$(/home/miqu3iasg/.local/bin/pomo.sh clock 2>/dev/null)
    
    if [[ -n "$pomo" ]]; then
        echo "$pomo   |   $line"
    else
        echo "$line"
    fi
done
