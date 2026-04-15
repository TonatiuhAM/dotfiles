#!/bin/bash

option=$(printf "Dev-Mode" | rofi -dmenu -p "Layout Menu" -theme "~/.config/rofi/launchers/main-style-11.rasi")

case "$option" in
"Dev-Mode") ~/dotfiles/endeavouros/hypr/.config/hypr/scripts/dev-layout.sh ;;
*) exit 1 ;;
esac
