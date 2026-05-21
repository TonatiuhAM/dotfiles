#!/usr/bin/env bash
# dev-workspace.sh — Workspace de desarrollo con selector de proyecto

DEV_DIR="$HOME/dev"
TMPFILE=$(mktemp /tmp/dev-workspace-XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT

# Fase 1: Selector flotante — bloquea hasta que kitty cierra
kitty --class dev-workspace-picker \
    -- bash -c "
        ls -d ${DEV_DIR}/*/ 2>/dev/null \
            | xargs -n1 basename \
            | fzf \
                --height=100% \
                --border=rounded \
                --prompt='  Dev > ' \
                --preview='ls ${DEV_DIR}/{}' \
                --preview-window=right:40% \
            > ${TMPFILE}
    "

PROJECT=$(cat "$TMPFILE")
[[ -z "$PROJECT" ]] && exit 0

# Fase 2: Terminal izquierda — trabajo general
kitty --class dev-workspace-main \
    --directory "$DEV_DIR/$PROJECT" &

sleep 0.3

# Fase 2: Terminal derecha — tmux con sesión inteligente
kitty --class dev-workspace-tmux \
    -- bash -c "
        if tmux has-session -t '$PROJECT' 2>/dev/null; then
            tmux attach-session -t '$PROJECT'
        else
            tmux new-session -s '$PROJECT' -c '$DEV_DIR/$PROJECT'
        fi
    " &

sleep 0.4

# Ajustar proporción 75/25: enfocar izq → dar 75% → devolver foco a derecha (tmux)
hyprctl dispatch movefocus l
hyprctl dispatch splitratio exact 0.75
hyprctl dispatch movefocus r
