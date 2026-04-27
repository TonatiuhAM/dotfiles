#!/usr/bin/env bash

# Script simple para abrir 3 terminales en un directorio de trabajo específico.

# --- CONFIGURACIÓN ---
# Directorio de trabajo para todas las terminales
WORK_DIR="/home/tona/dev/credittrack/"

# --- ABRIR TERMINALES ---
hyprctl dispatch exec "kitty --directory $WORK_DIR"
sleep 0.2
hyprctl dispatch exec "kitty --directory $WORK_DIR"
sleep 0.2
hyprctl dispatch exec "kitty --directory $WORK_DIR"
