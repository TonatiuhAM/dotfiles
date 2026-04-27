#!/bin/bash
# --- CONFIGURACIÓN ---
VAULT="the-vault"
MODE="append"

# 1. Capturar el texto con Rofi
TEXT=$(echo "" | rofi -dmenu -p "󰠮 Nueva idea:" \
  -config /dev/null \
  -theme "~/.config/rofi/launchers/main-style-11.rasi" \
  -theme-str 'window {width: 40%; font: "JetBrainsMono NF 12";} listview {enabled: false;}')

if [ -z "$TEXT" ]; then
  exit 0
fi

# 2. Formatear hora y construir texto
TIME=$(date +"%-I:%M%P")
FINAL_TEXT="${TIME}"$'\n'"- [ ] ${TEXT}"$'\n'

# 3. URL-encode
ENCODED_TEXT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$FINAL_TEXT'''))")

# 4. Construir URI
URI="obsidian://advanced-uri?vault=${VAULT}&daily=true&data=${ENCODED_TEXT}&mode=${MODE}"

# 5. Función: esperar hasta que Obsidian tenga ventana visible en Hyprland
wait_for_obsidian_window() {
  local MAX_WAIT=20
  local WAITED=0
  while [ $WAITED -lt $MAX_WAIT ]; do
    # hyprctl clients lista todas las ventanas abiertas en Hyprland
    if hyprctl clients -j 2>/dev/null | python3 -c \
      "import sys,json; clients=json.load(sys.stdin); exit(0 if any('obsidian' in c.get('class','').lower() or 'obsidian' in c.get('title','').lower() for c in clients) else 1)" 2>/dev/null; then
      return 0
    fi
    sleep 0.3
    WAITED=$(echo "$WAITED + 0.3" | bc)
  done
  return 1 # timeout
}

# 6. Arrancar Obsidian si no está corriendo
if ! pgrep -f "obsidian" >/dev/null 2>&1; then
  obsidian >/dev/null 2>&1 &
  wait_for_obsidian_window
  # Pequeña pausa mínima para que el vault termine de indexar
  sleep 0.8
fi

# 7. Enviar URI
xdg-open "$URI"
