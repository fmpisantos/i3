#!/bin/bash

cp -r .i3status/ ~/.config/bin/
chmod +x workspace-app-launcher.sh
chmod +x toggle-layout.sh
sudo cp ~/.config/i3/layouts/xkb/us /usr/share/X11/xkb/symbols/us
sudo cp ~/.config/i3/layouts/xkb/evdev.lst /usr/share/X11/xkb/rules/evdev.lst
sudo cp ~/.config/i3/layouts/xkb/evdev.xml /usr/share/X11/xkb/rules/evdev.xml
i3-msg reload
i3-msg restart
