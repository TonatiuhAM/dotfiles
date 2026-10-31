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
nohup qs >/dev/null 2>&1 &

# Si en el futuro regresas a waybar, hazlo igual:
# nohup waybar >/dev/null 2>&1 &
