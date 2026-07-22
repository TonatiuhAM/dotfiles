#!/usr/bin/env bash
# config-picker.sh — Selector rápido de configuraciones con Neovim

# Usar $XDG_CONFIG_HOME si está definida, de lo contrario usar el default estándar
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}"
TMPFILE=$(mktemp /tmp/config-picker-XXXXXX)
trap 'rm -f "$TMPFILE"' EXIT

# Fase 1: Selector flotante (Alacritty + fzf)
alacritty --class dev-workspace-picker \
  -e bash -c "
        ls -d ${CONFIG_DIR}/*/ 2>/dev/null \
            | xargs -n1 basename \
            | fzf \
                --height=100% \
                --border=rounded \
                --prompt=' Config > ' \
                --preview='ls -A ${CONFIG_DIR}/{}' \
                --preview-window=right:40% \
            > ${TMPFILE}
    "

SELECTED_DIR=$(cat "$TMPFILE")
[[ -z "$SELECTED_DIR" ]] && exit 0

TARGET_PATH="$CONFIG_DIR/$SELECTED_DIR"

# Contar cuántos archivos regulares hay dentro del directorio (sin contar carpetas)
FILE_COUNT=$(find "$TARGET_PATH" -maxdepth 1 -type f | wc -l)

# Fase 2: Abrir Neovim con la lógica de archivos
if [ "$FILE_COUNT" -eq 1 ]; then
  # Si solo hay 1 archivo, obtenemos su nombre completo
  SINGLE_FILE=$(find "$TARGET_PATH" -maxdepth 1 -type f)

  # Abrir Alacritty ejecutando nvim directamente sobre ese archivo
  alacritty --class dev-workspace-main \
    --working-directory "$TARGET_PATH" \
    -e bash -c "nvim '$SINGLE_FILE'" &
else
  # Si hay 0 o más de un archivo, abrir todo el directorio (nvim .)
  alacritty --class dev-workspace-main \
    --working-directory "$TARGET_PATH" \
    -e bash -c "nvim ." &
fi
