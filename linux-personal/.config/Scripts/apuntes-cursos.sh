#!/bin/bash

VAULT="/home/tona/Obsidian/the-vault/"

# Abrir kitty flotante con nvim
kitty --class apuntes-cursos -e nvim "$VAULT" &

# Abrir Obsidian
obsidian &
