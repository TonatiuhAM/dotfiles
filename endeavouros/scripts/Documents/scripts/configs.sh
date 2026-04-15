#!/bin/bash

option=$(printf "zsh\nhyprland\nrofi\nwaybar\nswaync\nmatugen\nkitty\nkeyd\nnvim\ntmux\nscripts\nmenus" | rofi -dmenu -p "Configuraciones" -theme "~/.config/rofi/launchers/main-style-11.rasi")

case "$option" in
"zsh") kitty --hold nvim "/home/tona/.zshrc" ;;
"hyprland") kitty --hold nvim "/home/tona/.config/hypr/hyprland.conf" ;;
"rofi") kitty --hold nvim "/home/tona/.config/rofi" ;;
"waybar") kitty --hold nvim "/home/tona/.config/waybar" ;;
"swaync") kitty --hold nvim "/home/tona/.config/swaync" ;;
"matugen") kitty --hold nvim "/home/tona/.config/matugen" ;;
"kitty") kitty --hold nvim "/home/tona/.config/kitty/kitty.conf" ;;
"keyd") kitty --hold nvim "/etc/keyd/default.conf" ;;
"nvim") kitty --hold nvim "/home/tona/.config/nvim" ;;
"tmux") kitty --hold nvim "/home/tona/.tmux.conf" ;;
"scripts") kitty --hold nvim "/home/tona/Documents/scripts/" ;;
"menus") kitty --hold nvim "/home/tona/.local/share/applications/" ;;
esac
