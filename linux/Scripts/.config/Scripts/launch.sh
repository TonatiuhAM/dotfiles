#!/bin/bash

# Recargar configuraciones de Hyprland y Pyprland
hyprctl reload
pypr reload

# Matar instancias previas de forma segura (añadimos || true para que no lance errores si no estaban abiertos)
killall -9 waybar || true
killall -9 qs || true

# Recargar el demonio de notificaciones
# swaync-client -R && swaync-client -rs

# Volver a lanzar quickshell en segundo plano e independizar el proceso
# (Redirigimos la salida a /dev/null para que no ensucie tu terminal o logs)
# lanzar ChillPill (sin argumentos qs cargaría ~/.config/quickshell/shell.qml, la barra vieja)
CHILLPILL="$HOME/.config/quickshell/chillpill"
QML_IMPORT_PATH="$CHILLPILL/build/qml" nohup qs -p "$CHILLPILL" >/dev/null 2>&1 &

# Si en el futuro regresas a waybar, hazlo igual:
# nohup waybar >/dev/null 2>&1 &
