#!/bin/bash
set -euo pipefail

# --- CONFIGURACIÓN ---
USUARIO=$(whoami)
TMUX_NAME="sunshine"
WAYLAND_TIMEOUT=30  # segundos máximos esperando Wayland

# Detectar nombre de sesión SDDM automáticamente
SESION=$(ls /usr/share/wayland-sessions/*.desktop 2>/dev/null \
    | grep -i hyprland | head -1 | xargs basename | sed 's/.desktop//')

if [[ -z "$SESION" ]]; then
    echo "ERROR: No se encontró sesión de Hyprland en /usr/share/wayland-sessions/"
    exit 1
fi

echo "=== Iniciando Bypass Dinámico de SDDM ==="
echo "-> Usuario: $USUARIO | Sesión: $SESION"

# 1. Crear autologin temporal
echo "-> Generando configuración temporal de Autologin..."
# Relogin=true es necesario para que SDDM aplique el autologin en un restart (no solo en arranque)
printf '[Autologin]\nUser=%s\nSession=%s\nRelogin=true\n' "$USUARIO" "$SESION" \
    | sudo tee /etc/sddm.conf.d/autologin.conf > /dev/null

# 2. Reiniciar SDDM (este script debe correr desde SSH/TTY, no desde la sesión gráfica)
echo "-> Reiniciando SDDM..."
sudo systemctl restart sddm

# 3. Esperar a que SDDM haya leído la config antes de borrarla
# systemctl restart retorna cuando el proceso arranca, no cuando termina de leer configs
sleep 3
echo "-> Limpiando autologin (protege arranques futuros)..."
sudo rm -f /etc/sddm.conf.d/autologin.conf

# 4. Esperar dinámicamente el socket de Wayland
echo "-> Esperando socket de Wayland (máx ${WAYLAND_TIMEOUT}s)..."
XDG_RUNTIME_DIR="/run/user/$(id -u)"
WAYLAND_DISPLAY=""

for i in $(seq 1 $WAYLAND_TIMEOUT); do
    SOCKET=$(ls "$XDG_RUNTIME_DIR"/wayland-* 2>/dev/null \
        | grep -v '\.lock' | head -1)
    if [[ -n "$SOCKET" ]]; then
        WAYLAND_DISPLAY=$(basename "$SOCKET")
        echo "-> Socket encontrado: $WAYLAND_DISPLAY (${i}s)"
        break
    fi
    sleep 1
done

if [[ -z "$WAYLAND_DISPLAY" ]]; then
    echo "ERROR: Wayland no arrancó en ${WAYLAND_TIMEOUT}s. Abortando."
    exit 1
fi

export XDG_RUNTIME_DIR
export WAYLAND_DISPLAY

# 5. Crear sesión tmux (o reutilizar si ya existe)
if tmux has-session -t "$TMUX_NAME" 2>/dev/null; then
    echo "-> Sesión tmux '$TMUX_NAME' ya existe, no se crea de nuevo."
else
    echo "-> Creando sesión tmux '$TMUX_NAME' y lanzando Sunshine..."
    tmux new-session -d -s "$TMUX_NAME" \
        "WAYLAND_DISPLAY=$WAYLAND_DISPLAY XDG_RUNTIME_DIR=$XDG_RUNTIME_DIR sunshine"
    echo ""
    echo "=== ¡Listo! Sunshine corriendo en tmux. ==="
    echo "-> Ver proceso:    tmux attach -t $TMUX_NAME"
    echo "-> Matar Sunshine: tmux kill-session -t $TMUX_NAME"
fi
