#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  apps.sh  —  Submódulo: Aplicaciones instaladas             ║
# ╚══════════════════════════════════════════════════════════════╝

THEME="$HOME/.config/rofi/themes/launcher.rasi"

# Rutas de búsqueda: estándar + flatpak sistema + flatpak usuario
DESKTOP_DIRS=(
  /usr/share/applications
  "$HOME/.local/share/applications"
  /var/lib/flatpak/exports/share/applications
  "$HOME/.local/share/flatpak/exports/share/applications"
)

# Construye lista "Nombre|Exec|Icon"
app_list=$(find "${DESKTOP_DIRS[@]}" \
               -name "*.desktop" 2>/dev/null \
           | while read -r f; do
               name=$(grep -m1 "^Name="     "$f" | cut -d= -f2-)
               exec_cmd=$(grep -m1 "^Exec=" "$f" | cut -d= -f2- \
                         | sed 's/ @@[^ ]*//g; s/ %[A-Za-z]//g; s/ --$//')
               icon=$(grep -m1 "^Icon="     "$f" | cut -d= -f2-)
               nodisplay=$(grep -m1 "^NoDisplay=" "$f" | cut -d= -f2-)
               [[ "$nodisplay" == "true" ]] && continue
               [[ -n "$name" && -n "$exec_cmd" ]] && echo "$name|$exec_cmd|$icon"
             done | sort -u)

selection=$(printf '%s\n' "$app_list" \
    | awk -F'|' '{
        if ($3 != "") printf "%s\0icon\x1f%s\n", $1, $3
        else printf "%s\n", $1
      }' \
    | rofi -dmenu \
           -p "" \
           -theme "$THEME" \
           -show-icons \
           -i)

[[ -z "$selection" ]] && exit 0

exec_cmd=$(printf '%s\n' "$app_list" \
    | awk -F'|' -v s="$selection" '$1==s {print $2; exit}')

[[ -n "$exec_cmd" ]] && setsid bash -c "$exec_cmd" &>/dev/null &
