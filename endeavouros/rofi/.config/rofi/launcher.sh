#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  launcher.sh  —  Menú principal                             ║
# ╚══════════════════════════════════════════════════════════════╝

ROFI_DIR="$HOME/.config/rofi"
THEME="$ROFI_DIR/themes/launcher.rasi"
MODS="$ROFI_DIR/modules"
APPS_CACHE="$HOME/.cache/rofi-launcher/apps.txt"

# ── Caché de apps ──────────────────────────────────────────────
# Se regenera en cada apertura del launcher (gawk lee todo en un solo proceso,
# ~50ms). Garantiza que apps recién instaladas aparezcan inmediatamente.
DESKTOP_DIRS=(
  /usr/share/applications
  "$HOME/.local/share/applications"
  /var/lib/flatpak/exports/share/applications
  "$HOME/.local/share/flatpak/exports/share/applications"
)

_refresh_cache() {
  local cache_dir tmp_cache
  cache_dir=$(dirname "$APPS_CACHE")
  mkdir -p "$cache_dir"
  tmp_cache="${APPS_CACHE}.tmp.$$"

  find "${DESKTOP_DIRS[@]}" -name "*.desktop" \
    -print0 2>/dev/null | xargs -0 gawk '
    BEGINFILE { name=""; icon=""; nodisplay=0 }
    /^Name=/      && !name      { name      = substr($0, 6) }
    /^Icon=/      && !icon      { icon      = substr($0, 6) }
    /^NoDisplay=/ && !nodisplay { nodisplay = (substr($0, 11) == "true") }
    ENDFILE { if (name && !nodisplay) print name "|" icon }
  ' 2>/dev/null | sort -u >"$tmp_cache" &&
    mv "$tmp_cache" "$APPS_CACHE"
}

# ── Construye lista unificada ──────────────────────────────────
build_list() {
  echo "󰣆  Aplicaciones"
  echo "󰏘  Style"
  echo "󰆍  Scripts"
  echo "󰐥  System"
  echo "󰣀  SSH"

  # Apps desde caché (instantáneo)
  [[ -f "$APPS_CACHE" ]] && awk -F'|' '{
      if ($2 != "") printf "  %s\0icon\x1f%s\n", $1, $2
      else printf "  %s\n", $1
  }' "$APPS_CACHE"

  # Aliases de mensajería → Ferdium
  printf "  WhatsApp\0icon\x1fferdium\n"
  printf "  Discord\0icon\x1fferdium\n"

  # Scripts / configs
  printf "  zsh\n  hyprland\n  rofi\n  waybar\n  swaync\n"
  printf "  matugen\n  kitty\n  keyd\n  nvim\n  tmux\n"
  printf "  scripts\n  menus\n  yazi\n  Dev-Mode\n"

  # System
  printf "  Apagar\n  Reiniciar\n  Bloquear\n"
}

# Reconstruye el caché siempre — garantiza apps recién instaladas visibles
_refresh_cache

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
"󰣀  SSH") exec bash "$MODS/ssh.sh" ;;
esac

# ── Búsqueda unificada ─────────────────────────────────────────

# ¿App?
if [[ -f "$APPS_CACHE" ]] && awk -F'|' -v n="$clean" '$1==n{found=1}END{exit !found}' "$APPS_CACHE"; then
  exec_cmd=$(find "${DESKTOP_DIRS[@]}" \
    -name "*.desktop" 2>/dev/null |
    while read -r f; do
      name=$(grep -m1 "^Name=" "$f" | cut -d= -f2-)
      exc=$(grep -m1 "^Exec=" "$f" | cut -d= -f2- |
        sed 's/ @@[^ ]*//g; s/ %[A-Za-z]//g; s/ --$//')
      [[ "$name" == "$clean" ]] && echo "$exc" && break
    done)
  if [[ -n "$exec_cmd" ]]; then
    if [[ "$exec_cmd" != *" "* ]]; then
      setsid "$exec_cmd" </dev/null &>/dev/null &
    else
      setsid bash -c "$exec_cmd" </dev/null &>/dev/null &
    fi
  fi
  exit 0
fi

# ¿Alias mensajería?
case "$clean" in
"WhatsApp" | "Discord")
  (setsid env ELECTRON_IS_DEV=0 /usr/bin/electron37 /opt/ferdium-bin/ --ozone-platform=wayland --enable-features=UseOzonePlatform,WaylandWindowDecorations </dev/null &>/dev/null &)
  exit 0
  ;;
esac

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
yazi) kitty nvim "/home/tona/.config/yazi" ;;
scripts) kitty nvim "/home/tona/Documents/scripts/" ;;
menus) kitty nvim "/home/tona/.local/share/applications/" ;;
esac
