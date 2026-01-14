#!/bin/bash

# Resolution configuration
# Array of available resolutions for external monitor
RESOLUTIONS=(
    "3840x2160"   # 0: 4K
    "2560x1440"   # 1: 2K / QHD
    "1920x1080"   # 2: 1080p / Full HD
    "1680x1050"   # 3: WSXGA+
    "1280x720"    # 4: 720p / HD
)

# Set to -1 for auto-detection, or 0-4 to force a specific resolution from the array above
FORCE_RESOLUTION_INDEX=2

# Restart all Thunderbolt (DP) and HDMI ports to force re-detection
echo "Restarting external display ports..."

# Get all DP and HDMI outputs (excluding internal eDP)
EXTERNAL_OUTPUTS=$(xrandr | grep -E "^(DP|HDMI)-" | awk '{print $1}')

# Turn off all external outputs
for output in $EXTERNAL_OUTPUTS; do
    echo "Turning off $output..."
    xrandr --output "$output" --off
done

# Delay to allow hardware to reset
sleep 2

# Re-enable all external outputs to trigger detection
for output in $EXTERNAL_OUTPUTS; do
    echo "Re-enabling $output..."
    xrandr --output "$output" --auto
done

# Delay to allow monitors to be detected
sleep 2

echo "Searching for active monitors..."

# Search for connected external monitor (DP or HDMI, excluding eDP which is the laptop)
CONNECTED_EXTERNAL=$(xrandr | grep " connected" | grep -v "^eDP" | grep -E "^(DP|HDMI)-[0-9]" | awk '{print $1}' | head -n 1)

if [ -z "$CONNECTED_EXTERNAL" ]; then
    echo "No connected external monitor found. Setting eDP-1 as primary."
    xrandr --output eDP-1 --primary --auto
else
    echo "Found connected external monitor: $CONNECTED_EXTERNAL"
    
    # Build the xrandr command for proper extended display setup
    # First, turn off all external outputs again to reset positioning
    for output in $EXTERNAL_OUTPUTS; do
        xrandr --output "$output" --off
    done
    
    # Now set up the displays properly: external as primary on the left, laptop on the right
    if [ "$FORCE_RESOLUTION_INDEX" -ge 0 ] && [ "$FORCE_RESOLUTION_INDEX" -lt "${#RESOLUTIONS[@]}" ]; then
        FORCED_RES="${RESOLUTIONS[$FORCE_RESOLUTION_INDEX]}"
        echo "Setting up extended display with forced resolution: $FORCED_RES"
        xrandr \
            --output eDP-1 --auto \
            --output "$CONNECTED_EXTERNAL" --primary --mode "$FORCED_RES" --left-of eDP-1
    else
        echo "Setting up extended display with auto-detected resolution"
        xrandr \
            --output eDP-1 --auto \
            --output "$CONNECTED_EXTERNAL" --primary --auto --left-of eDP-1
    fi
fi

~/.config/i3/set-wallpaper.sh

# Restart i3 to apply workspace assignments to monitors
i3-msg restart
