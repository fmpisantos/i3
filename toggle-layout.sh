#!/bin/bash
current=$(setxkbmap -query | grep layout | awk '{print $2}' | cut -d',' -f1)
if [[ $current == "us" ]]; then
    setxkbmap pt
    echo "PT" > /tmp/current_layout
else
    setxkbmap us swapped
    echo "EN" > /tmp/current_layout
fi
