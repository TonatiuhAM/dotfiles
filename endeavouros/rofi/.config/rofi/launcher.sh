#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  launcher.sh  —  Menú principal                             ║
# ╚══════════════════════════════════════════════════════════════╝

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/launcher.rasi"
MODS="$ROFI_DIR/modules"
APPS_CACHE="$HOME/.cache/rofi-launcher/apps.txt"

# ── Caché de apps ──────────────────────────────────────────────
# Se regenera solo si algún .desktop cambió desde la última vez.
# En caso normal (sin instalar apps nuevas) es instantáneo.
DESKTOP_DIRS=(
  /usr/share/applications
  "$HOME/.local/share/applications"
  /var/lib/flatpak/exports/share/applications
  "$HOME/.local/share/flatpak/exports/share/applications"
)

_refresh_cache() {
  local cache_dir
  cache_dir=$(dirname "$APPS_CACHE")
  mkdir -p "$cache_dir"

  # Fecha del .desktop más reciente
  local newest
  newest=$(find "${DESKTOP_DIRS[@]}" \
    -name "*.desktop" 2>/dev/null |
    xargs stat -c "%Y" 2>/dev/null |
    sort -n | tail -1)

  # Fecha del caché actual
  local cache_time=0
  [[ -f "$APPS_CACHE" ]] && cache_time=$(stat -c "%Y" "$APPS_CACHE" 2>/dev/null)

  # Solo reconstruye si hay archivos más nuevos que el caché
  if [[ "$newest" -gt "$cache_time" ]]; then
    find "${DESKTOP_DIRS[@]}" \
      -name "*.desktop" 2>/dev/null |
      while read -r f; do
        local name icon nodisplay
        name=$(grep -m1 "^Name=" "$f" | cut -d= -f2-)
        icon=$(grep -m1 "^Icon=" "$f" | cut -d= -f2-)
        nodisplay=$(grep -m1 "^NoDisplay=" "$f" | cut -d= -f2-)
        [[ "$nodisplay" == "true" ]] && continue
        [[ -n "$name" ]] && echo "$name|$icon"
      done | sort -u >"$APPS_CACHE"
  fi
}

# ── Construye lista unificada ──────────────────────────────────
build_list() {
  echo "󰣆  Aplicaciones"
  echo "󰏘  Style"
  echo "󰆍  Scripts"
  echo "󰐥  System"

  # Apps desde caché (instantáneo)
  [[ -f "$APPS_CACHE" ]] && awk -F'|' '{
      if ($2 != "") printf "  %s\0icon\x1f%s\n", $1, $2
      else printf "  %s\n", $1
  }' "$APPS_CACHE"

  # Scripts / configs
  printf "  zsh\n  hyprland\n  rofi\n  waybar\n  swaync\n"
  printf "  matugen\n  kitty\n  keyd\n  nvim\n  tmux\n"
  printf "  scripts\n  menus\n  Dev-Mode\n"

  # System
  printf "  Apagar\n  Reiniciar\n  Bloquear\n"
}

# Refresca el caché en background — no bloquea la apertura del menú
_refresh_cache &

# ── Lanza rofi ─────────────────────────────────────────────────
selection=$(build_list |
  rofi -dmenu \
    -p "" \
    -theme "$THEME" \
    -theme-str 'listview { lines: 4; fixed-height: false; dynamic: true; }' \
    -show-icons \
    -i \
    -no-custom \
    -selected-row 0)

[[ -z "$selection" ]] && exit 0

clean="${selection#"  "}"

# ── Despacha ───────────────────────────────────────────────────
case "$selection" in
"󰣆  Aplicaciones") exec bash "$MODS/apps.sh" ;;
"󰏘  Style") exec bash "$MODS/style-picker.sh" ;;
"󰆍  Scripts") exec bash "$MODS/scripts.sh" ;;
"󰐥  System") exec bash "$MODS/system.sh" ;;
esac

# ── Búsqueda unificada ─────────────────────────────────────────

# ¿App?
if [[ -f "$APPS_CACHE" ]] && awk -F'|' -v n="$clean" '$1==n{found=1}END{exit !found}' "$APPS_CACHE"; then
  exec_cmd=$(find "${DESKTOP_DIRS[@]}" \
    -name "*.desktop" 2>/dev/null |
    while read -r f; do
      name=$(grep -m1 "^Name=" "$f" | cut -d= -f2-)
      exc=$(grep -m1 "^Exec=" "$f" | cut -d= -f2- \
           | sed 's/ @@[^ ]*//g; s/ %[A-Za-z]//g; s/ --$//')
      [[ "$name" == "$clean" ]] && echo "$exc" && break
    done)
  [[ -n "$exec_cmd" ]] && setsid bash -c "$exec_cmd" &>/dev/null &
  exit 0
fi

# ¿System?
case "$clean" in
"Apagar")
  poweroff
  exit 0
  ;;
"Reiniciar")
  reboot
  exit 0
  ;;
"Bloquear")
  hyprlock
  exit 0
  ;;
"Dev-Mode")
  bash "$HOME/dotfiles/endeavouros/scripts/Documents/scripts/hypr-scripts/dev-layout.sh"
  exit 0
  ;;
esac

# ¿Config?
case "$clean" in
zsh) kitty nvim "/home/tona/.zshrc" ;;
hyprland) kitty nvim "/home/tona/.config/hypr/hyprland.conf" ;;
rofi) kitty nvim "/home/tona/.config/rofi" ;;
waybar) kitty nvim "/home/tona/.config/waybar" ;;
swaync) kitty nvim "/home/tona/.config/swaync" ;;
matugen) kitty nvim "/home/tona/.config/matugen" ;;
kitty) kitty nvim "/home/tona/.config/kitty/kitty.conf" ;;
keyd) kitty nvim "/etc/keyd/default.conf" ;;
nvim) kitty nvim "/home/tona/.config/nvim" ;;
tmux) kitty nvim "/home/tona/.tmux.conf" ;;
scripts) kitty nvim "/home/tona/Documents/scripts/" ;;
menus) kitty nvim "/home/tona/.local/share/applications/" ;;
esac
