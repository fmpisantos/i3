#!/bin/bash
CONNECTED_DP_OUTPUT=$(xrandr | grep " connected" | grep -E "DP-[0-9]+-1" | awk '{print $1}' | head -n 1)

if [ -z "$CONNECTED_DP_OUTPUT" ]; then
    echo "No connected DP-x-1 output found. Setting eDP-1 as primary."
    xrandr --output eDP-1 --primary --auto
else
    echo "Found connected DP output: $CONNECTED_DP_OUTPUT. Setting as primary."
    xrandr --output "$CONNECTED_DP_OUTPUT" --primary --auto --left-of eDP-1 --auto
fi
