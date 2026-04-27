#!/bin/bash

option=$(printf "zsh\nhyprland\nrofi\nwaybar\nswaync\nmatugen\nkitty\nkeyd\nnvim\ntmux\nscripts\nmenus" | rofi -dmenu -p "Configuraciones" -theme "~/.config/rofi/launchers/main-style-11.rasi")

case "$option" in
"zsh") kitty nvim "/home/tona/.zshrc" ;;
"hyprland") kitty nvim "/home/tona/.config/hypr/hyprland.conf" ;;
"rofi") kitty nvim "/home/tona/.config/rofi" ;;
"waybar") kitty nvim "/home/tona/.config/waybar" ;;
"swaync") kitty nvim "/home/tona/.config/swaync" ;;
"matugen") kitty nvim "/home/tona/.config/matugen" ;;
"kitty") kitty nvim "/home/tona/.config/kitty/kitty.conf" ;;
"keyd") kitty nvim "/etc/keyd/default.conf" ;;
"nvim") kitty nvim "/home/tona/.config/nvim" ;;
"tmux") kitty nvim "/home/tona/.tmux.conf" ;;
"scripts") kitty nvim "/home/tona/Documents/scripts/" ;;
"menus") kitty nvim "/home/tona/.local/share/applications/" ;;
esac
