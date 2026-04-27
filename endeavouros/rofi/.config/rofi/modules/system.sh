#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  system.sh  —  Submódulo: Power menu                        ║
# ║  (integra powermenu.sh)                                     ║
# ╚══════════════════════════════════════════════════════════════╝

THEME="$HOME/.config/rofi/themes/launcher.rasi"

selection=$(printf "Apagar\nReiniciar\nBloquear" \
    | rofi -dmenu \
           -p "󰐥" \
           -theme "$THEME" \
           -no-custom \
           -i)

[[ -z "$selection" ]] && exit 0

case "$selection" in
    "Apagar")    poweroff ;;
    "Reiniciar") reboot   ;;
    "Bloquear")  hyprlock ;;
esac
