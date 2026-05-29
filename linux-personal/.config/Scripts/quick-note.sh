#!/bin/bash

VAULT="the-vault"
NOTE="Sticky%20Notes.md"
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
  # Codificar el texto con salto de línea al inicio (espacio en blanco)
  ENCODED_TEXT=$(python3 -c "
import urllib.parse
text = open('${TMPFILE}').read()
print(urllib.parse.quote('\n' + text))
")

  # Primero abrir Obsidian para asegurarse de que esté corriendo
  xdg-open "obsidian://open?vault=${VAULT}"
  sleep 1.5

  # Luego hacer append a Sticky Notes.md
  URI="obsidian://advanced-uri?vault=${VAULT}&filepath=${NOTE}&data=${ENCODED_TEXT}&mode=append"
  xdg-open "$URI"
fi

# Limpiar archivo temporal
rm -f "$TMPFILE"
