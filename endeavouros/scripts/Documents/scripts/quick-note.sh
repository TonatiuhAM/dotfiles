#!/bin/bash

VAULT="the-vault"
MODE="append"
TMPFILE=$(mktemp /tmp/quick-note-XXXXXX.md)

# Abrir kitty flotante con nvim editando el archivo temporal
kitty --override font_size=13 \
  --override initial_window_width=600 \
  --override initial_window_height=400 \
  --class quick-note \
  -e nvim "$TMPFILE"

# Una vez que nvim se cierra, leer el contenido
FINAL_TEXT=$(cat "$TMPFILE")

# Solo hacer append si hay contenido
if [ -n "$FINAL_TEXT" ]; then
  ENCODED_TEXT=$(python3 -c "import urllib.parse; print(urllib.parse.quote('''$FINAL_TEXT'''))")
  URI="obsidian://advanced-uri?vault=${VAULT}&daily=true&data=${ENCODED_TEXT}&mode=${MODE}"
  xdg-open "$URI"
fi

# Limpiar archivo temporal
rm -f "$TMPFILE"
