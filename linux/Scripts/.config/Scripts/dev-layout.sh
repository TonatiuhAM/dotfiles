#!/usr/bin/env bash
# dev-layout.sh — Workspace de desarrollo (terminal + tmux lado a lado)
#
# Usa tmux-sessionizer.sh para elegir/crear la sesión de tmux (fzf +
# zoxide, cualquier carpeta), y arma un layout de Hyprland 75/25 con una
# terminal normal a la izquierda y la sesión de tmux a la derecha.

TMPFILE=$(mktemp /tmp/dev-layout-XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT

# Fase 1: Selector flotante — bloquea hasta que alacritty cierra.
# --create-only: crea/localiza la sesión pero no hace attach aquí, solo
# imprime su nombre (el attach real ocurre en la Fase 2, terminal derecha).
alacritty --class dev-workspace-picker \
    -e bash -c "\$XDG_CONFIG_HOME/Scripts/tmux-sessionizer.sh --create-only > ${TMPFILE}"

SESSION=$(cat "$TMPFILE")
[[ -z "$SESSION" ]] && exit 0

# Directorio de trabajo de la sesión elegida (para la terminal izquierda)
CWD=$(tmux display-message -p -t "$SESSION" '#{pane_current_path}')

# Fase 2: Terminal izquierda — trabajo general
alacritty --class dev-workspace-main \
    --working-directory "$CWD" &

sleep 0.3

# Fase 2: Terminal derecha — sesión de tmux elegida
alacritty --class dev-workspace-tmux \
    -e bash -c "tmux attach-session -t '$SESSION'" &

sleep 0.4

# Ajustar proporción 75/25: enfocar izq → dar 75% → devolver foco a derecha (tmux)
hyprctl dispatch movefocus l
hyprctl dispatch splitratio exact 0.75
hyprctl dispatch movefocus r
