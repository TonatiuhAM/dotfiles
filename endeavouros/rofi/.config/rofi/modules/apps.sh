#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  apps.sh  —  Submódulo: Aplicaciones instaladas             ║
# ╚══════════════════════════════════════════════════════════════╝

THEME="$HOME/.config/rofi/themes/launcher.rasi"

# Construye lista "Nombre|Exec" y muestra solo los nombres
app_list=$(find /usr/share/applications ~/.local/share/applications \
               -name "*.desktop" 2>/dev/null \
           | while read -r f; do
               name=$(grep -m1 "^Name="     "$f" | cut -d= -f2-)
               exec_cmd=$(grep -m1 "^Exec=" "$f" | cut -d= -f2- | sed 's/ %.*//')
               nodisplay=$(grep -m1 "^NoDisplay=" "$f" | cut -d= -f2-)
               [[ "$nodisplay" == "true" ]] && continue
               [[ -n "$name" && -n "$exec_cmd" ]] && echo "$name|$exec_cmd"
             done | sort -u)

selection=$(echo "$app_list" \
    | awk -F'|' '{print $1}' \
    | rofi -dmenu \
           -p "󰣆" \
           -theme "$THEME" \
           -i)

[[ -z "$selection" ]] && exit 0

exec_cmd=$(echo "$app_list" \
    | awk -F'|' -v s="$selection" '$1==s {print $2; exit}')

[[ -n "$exec_cmd" ]] && setsid bash -c "$exec_cmd" &>/dev/null &
