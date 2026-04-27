#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  scripts.sh  —  Submódulo: Scripts                          ║
# ║  (integra configs.sh + layout-menu.sh)                      ║
# ║                                                             ║
# ║  Uso normal:   bash scripts.sh                              ║
# ║  Ir directo a configs: bash scripts.sh configs              ║
# ║  Bind hyprland: $mainMod, COMMA, exec,                      ║
# ║    bash ~/.config/rofi/modules/scripts.sh configs           ║
# ╚══════════════════════════════════════════════════════════════╝

THEME="$HOME/.config/rofi/themes/launcher.rasi"

# Si se llama con "configs" salta directo a la lista de configuraciones
if [[ "$1" == "configs" ]]; then
  section="Configuraciones"
else
  section=$(printf "Configuraciones\nDev-Mode" |
    rofi -dmenu \
      -p "󰆍" \
      -theme "$THEME" \
      -no-custom \
      -i)
  [[ -z "$section" ]] && exit 0
fi

case "$section" in

# ── Configuraciones (configs.sh) ──────────────────────────
"Configuraciones")
  selection=$(printf \
    "zsh\nhyprland\nrofi\nwaybar\nswaync\nmatugen\nkitty\nkeyd\nnvim\ntmux\nscripts\nmenus" |
    rofi -dmenu \
      -p "󰒓" \
      -theme "$THEME" \
      -i)

  [[ -z "$selection" ]] && exit 0

  case "$selection" in
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
  ;;

# ── Layouts (layout-menu.sh) ──────────────────────────────
"Dev-Mode")
  bash "$HOME/dotfiles/endeavouros/scripts/Documents/scripts/hypr-scripts/dev-layout.sh"
  ;;
esac
