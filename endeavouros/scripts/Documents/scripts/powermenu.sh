#!/bin/bash

option=$(printf "Apagar\nReiniciar\nBloquear" | rofi -dmenu -p "Power Menu" -theme "~/.config/rofi/launchers/main-style-11.rasi")

case "$option" in
"Apagar") poweroff ;;
"Reiniciar") reboot ;;
"Bloquear") ~/.config/hyprlock/scripts/hyprlock.sh ;;
*) exit 1 ;;
esac
