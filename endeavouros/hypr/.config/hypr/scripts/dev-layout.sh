#!/usr/bin/env bash

# Definimos el directorio para reutilizarlo fácilmente
TARGET_DIR="~/dotfiles/endeavouros/"

# 1. Abrir Neovim a la izquierda (ocupa todo al inicio)
# --directory establece el CWD y -e ejecuta el comando
hyprctl dispatch exec "kitty --class nvim_term --directory $TARGET_DIR -e nvim"
sleep 0.4

# 2. Abrir el Agente de IA (opencode) a la derecha
hyprctl dispatch exec "kitty --class ai_term --directory $TARGET_DIR -e opencode"
sleep 0.4

# Ajustamos el ratio para que Nvim (izquierda) ocupe el 75% (3/4)
# Como estamos enfocados en la segunda ventana, un ratio de 0.25 la reduce al cuarto derecho
hyprctl dispatch splitratio 0.25

# Movemos el foco a la derecha para dividir esa columna específicamente
hyprctl dispatch movefocus r

# 3. Abrir la terminal de comandos abajo a la derecha
# Solo abrimos la terminal en el directorio, sin ejecutar programa extra
hyprctl dispatch exec "kitty --class cmd_term --directory $TARGET_DIR"
sleep 0.4

# Ajustamos el ratio vertical para que la IA ocupe el 75% de la altura de esa columna
hyprctl dispatch splitratio 0.25
