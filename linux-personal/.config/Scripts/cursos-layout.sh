#!/bin/bash

VAULT="/home/tona/Obsidian/the-vault/"

# Abrir kitty flotante con nvim
kitty --class apuntes-cursos -e nvim "$VAULT" &

# Abrir Obsidian
hyprctl dispatch 'hl.dsp.workspace.toggle_special("M")'
obsidian &
sleep 2
hyprctl dispatch 'hl.dsp.workspace.toggle_special("M")'
