#!/bin/bash

option=$(printf "Dev-Mode" | rofi -dmenu -p "Layout Menu" -theme "~/.config/rofi/launchers/main-style-11.rasi")

case "$option" in
"Dev-Mode") ~/dotfiles/endeavouros/scripts/Documents/scripts/hypr-scripts/dev-layout.sh ;;
*) exit 1 ;;
esac
