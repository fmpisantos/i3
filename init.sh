#!/bin/bash

cp -r .i3status/ ~/.config/bin/
chmod +x workspace-app-launcher.sh
chmod +x toggle-layout.sh
i3-msg reload
i3-msg restart
