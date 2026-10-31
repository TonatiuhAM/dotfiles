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
  section=$(printf "Apps\nDev-Mode\nSSH" |
    rofi -dmenu \
      -p "" \
      -theme "$THEME" \
      -no-custom \
      -i)
  [[ -z "$section" ]] && exit 0
fi

case "$section" in

# ── Layouts (layout-menu.sh) ──────────────────────────────
"Apps")
  exec bash "$XDG_CONFIG_HOME/Scripts/sysman.sh"
  ;;

"Dev-Mode")
  exec bash "$XDG_CONFIG_HOME/Scripts/dev-layout.sh"
  ;;

"SSH")
  exec bash "$HOME/.config/rofi/modules/ssh.sh"
  ;;
esac
