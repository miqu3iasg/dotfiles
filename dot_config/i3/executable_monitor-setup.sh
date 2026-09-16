#!/bin/bash

LOG="/tmp/monitor-setup.log"
echo "--- $(date) ---" >> "$LOG"

# Small delay to ensure X has already detected all outputs
# (prevents false negatives immediately after a cold boot)
sleep 1

if xrandr --query | grep -q "HDMI-1 connected"; then
    echo "HDMI-1 detected, loading externo profile" >> "$LOG"
    autorandr --load externo >> "$LOG" 2>&1

    feh --bg-scale ~/wallpapers/black.jpg ~/wallpapers/medusa.png
else
    echo "HDMI-1 not detected, loading notebook profile" >> "$LOG"
    autorandr --load notebook >> "$LOG" 2>&1

    feh --bg-scale ~/wallpapers/medusa.png
fi

echo "Current state: $(autorandr --current)" >> "$LOG"
</parameter>
