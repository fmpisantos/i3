#!/bin/bash
current=$(setxkbmap -query | grep layout | awk '{print $2}' | cut -d',' -f1)
if [[ $current == "us" ]]; then
    setxkbmap pt super_l_f14
    echo "PT" > /tmp/current_layout
else
    setxkbmap us swapped
    echo "EN" > /tmp/current_layout
fi
