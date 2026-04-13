#!/bin/bash

# --- CONFIGURACIÓN ---
VAULT="the-vault" # Asegúrate de que coincida con el nombre de tu bóveda en Obsidian
MODE="append"     # "append" para el final de la nota, "prepend" para el inicio

# 1. Capturar el texto con Rofi
# El flag -p cambia el prompt, -dmenu lo pone en modo entrada de texto
TEXT=$(echo "" | rofi -dmenu -p "󰠮 Nueva idea:" -config /dev/null -theme "~/.config/rofi/launchers/type-1/style-11.rasi" -theme-str 'window {width: 40%; font: "JetBrainsMono NF 12";} listview {enabled: false;}')
-dmenu -p "Power Menu"

# Salir si el usuario presiona ESC o no escribe nada
if [ -z "$TEXT" ]; then
  exit 0
fi

# 2. Formatear la hora en 12h (ej: 5:30pm)
# %-I elimina el cero inicial, %M los minutos y %P el am/pm en minúsculas
TIME=$(date +"%-I:%M%P")

# 3. Construir el bloque de texto con los saltos de línea solicitados
# Usamos $'\n' para representar los saltos de línea reales en Bash
FINAL_TEXT="${TIME}"$'\n'"- [ ] ${TEXT}"$'\n'

# 3. URL-encode (necesario para que Obsidian entienda espacios y símbolos)
ENCODED_TEXT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$FINAL_TEXT'''))")

# 4. Enviar a Obsidian mediante Advanced URI
URI="obsidian://advanced-uri?vault=${VAULT}&daily=true&data=${ENCODED_TEXT}&mode=${MODE}"

xdg-open "$URI"
