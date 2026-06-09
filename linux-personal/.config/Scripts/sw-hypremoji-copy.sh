#!/usr/bin/env bash

# 1. Limpiar cualquier intento previo de bloqueo del portapapeles
wl-copy --clear

# 2. Ejecutar hypremojis y esperar a que termine su interfaz
hypremoji
sleep 0.1 # Pequeño respiro para que el sistema registre la acción

# 3. Capturar lo que hypremojis haya intentado dejar en el portapapeles
EMOJI=$(wl-paste -n 2>/dev/null)

# 4. Si logró capturar un emoji, forzar su persistencia en Wayland
if [ -n "$EMOJI" ]; then
  # El truco: 'wl-copy' duplica el contenido de forma segura e independiente
  echo -n "$EMOJI" | wl-copy --background

  # Opcional: Una notificación sutil para que sepas que ya está listo para usarse
  # notify-send "Copiado" "$EMOJI listo para pegar"
fi
