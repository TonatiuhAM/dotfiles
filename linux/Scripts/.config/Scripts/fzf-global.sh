#!/usr/bin/env bash

# Si se ejecuta fuera de una terminal (ej. atajo global), abre fzf en una ventana flotante/interactiva
if [ ! -t 0 ]; then
  alacritty --class "fzf-global" -e "$0"
  exit 0
fi

# Lanza fzf y captura la selección
target=$(fzf --preview 'bat --style=numbers --color=always {} 2>/dev/null || cat {} 2>/dev/null || ls -la {}' \
  --preview-window=right:60%) || exit 0

[ -z "$target" ] && exit 0

target=$(realpath "$target")

# Busca la raíz del proyecto (marcador .git/.hg/.svn) subiendo desde el
# archivo/carpeta seleccionado, sin pasar de $HOME. Así nvim abre con el
# proyecto completo como directorio de trabajo (para poder hacer fzf de
# todo el proyecto) aunque el archivo elegido esté varios niveles abajo.
find_project_root() {
  local dir="$1"
  [ -d "$dir" ] || dir=$(dirname "$dir")
  while [ "$dir" != "/" ]; do
    if [ -e "$dir/.git" ] || [ -e "$dir/.hg" ] || [ -e "$dir/.svn" ]; then
      echo "$dir"
      return 0
    fi
    [ "$dir" = "$HOME" ] && break
    dir=$(dirname "$dir")
  done
  return 1
}

root=$(find_project_root "$target")

# Determina el directorio de trabajo: la raíz del proyecto si se detectó,
# o el comportamiento anterior (carpeta del propio target) si no.
if [ -d "$target" ]; then
  cwd="${root:-$target}"
else
  cwd="${root:-$(dirname "$target")}"
fi

setsid alacritty --working-directory "$cwd" -e nvim "$target" >/dev/null 2>&1 &

# Da tiempo a que la nueva ventana se independice antes de que esta
# terminal (la del picker, lanzada por el keybind) se cierre. Sin esto,
# al invocar el script vía keybind de Hyprland, la ventana de alacritty
# recién lanzada muere junto con la terminal del picker (race condition).
sleep 0.3
