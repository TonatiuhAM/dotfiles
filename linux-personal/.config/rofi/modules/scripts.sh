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
  section=$(printf "Configuraciones\nDev-Mode\nSSH" |
    rofi -dmenu \
      -p "" \
      -theme "$THEME" \
      -no-custom \
      -i)
  [[ -z "$section" ]] && exit 0
fi

case "$section" in

# ── Configuraciones (configs.sh) ──────────────────────────
"Configuraciones")
  selection=$(printf \
    "zsh\nhyprland\nrofi\nwaybar\nswaync\nmatugen\nkitty\nkeyd\nnvim\ntmux\nyazi\nscripts\nmenus" |
    rofi -dmenu \
      -p "" \
      -theme "$THEME" \
      -i)

  [[ -z "$selection" ]] && exit 0

  case "$selection" in
  zsh) kitty nvim "$XDG_CONFIG_HOME/zsh/.zshrc" ;;
  hyprland) kitty nvim "$XDG_CONFIG_HOME/hypr/hyprland.lua" ;;
  rofi) kitty nvim "$XDG_CONFIG_HOME/rofi" ;;
  waybar) kitty nvim "$XDG_CONFIG_HOME/waybar" ;;
  swaync) kitty nvim "$XDG_CONFIG_HOME/swaync" ;;
  matugen) kitty nvim "$XDG_CONFIG_HOME/matugen" ;;
  kitty) kitty nvim "$XDG_CONFIG_HOME/kitty" ;;
  keyd) kitty nvim "$KEYD_CONF" ;;
  nvim) kitty nvim "$XDG_CONFIG_HOME/nvim" ;;
  tmux) kitty nvim "$XDG_CONFIG_HOME/tmux" ;;
  yazi) kitty nvim "$XDG_CONFIG_HOME/yazi" ;;
  scripts) kitty nvim "$XDG_CONFIG_HOME/Scripts" ;;
  menus) kitty nvim "$APPS_DIR" ;;
  esac
  ;;

# ── Layouts (layout-menu.sh) ──────────────────────────────
"Dev-Mode")
  bash "$XDG_CONFIG_HOME/Scripts/hypr-scripts/dev-layout.sh"
  ;;

"SSH")
  exec bash "$HOME/.config/rofi/modules/ssh.sh"
  ;;
esac
