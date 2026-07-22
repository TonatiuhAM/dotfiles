#!/usr/bin/env bash
# ============================================================
#  sysman — Gestor Interactivo de Paquetes (Nativo, AUR, Brew, Flatpak)
# ============================================================

# ── Auto-relanzamiento en ventana dedicada de Alacritty ──────
# Si no estamos dentro de una ventana con el identificador de clase "Repositorios"
# y el comando alacritty está disponible, relanzamos el script de forma aislada.
if [[ "$1" != "--child" && ! -t 0 ]]; then
  setsid alacritty --class Repositorios -o font.size=16 -e "$0" --child </dev/null &>/dev/null &
  exit 0
fi

# Desplazar los argumentos si se usó la bandera interna de relanzamiento
[[ "$1" == "--child" ]] && shift

# ── Colores ──────────────────────────────────────────────────
R='\033[0;31m' # rojo
G='\033[0;32m' # verde
Y='\033[1;33m' # amarillo
B='\033[0;34m' # azul
C='\033[0;36m' # cyan
M='\033[0;35m' # magenta
W='\033[1;37m' # blanco brillante
DIM='\033[2m'  # tenue
BOLD='\033[1m'
RESET='\033[0m'

# ── Encabezado Gráfico ───────────────────────────────────────
print_header() {
  clear
  echo ""
  echo -e "  ${BOLD}${M}╔══════════════════════════════════════════╗${RESET}"
  echo -e "  ${BOLD}${M}║${RESET}  ${W}${BOLD}sysman${RESET} — Package Management Suite     ${BOLD}${M}║${RESET}"
  echo -e "  ${BOLD}${M}╚══════════════════════════════════════════╝${RESET}"
  echo ""
}

# ── Red de protección: Timeshift ────────────────────────────
run_timeshift() {
  echo -e "${Y}🛡️  Iniciando respaldo de seguridad con Timeshift...${RESET}"
  echo -e "${DIM}------------------------------------------------------------${RESET}"
  sudo timeshift --create --comments "sysman snapshot autogenerado"
  if [ $? -eq 0 ]; then
    echo -e "\n${G}✓ Snapshot creado exitosamente.${RESET}\n"
  else
    echo -e "\n${R}✕ Error al crear el snapshot de Timeshift.${RESET}"
    echo -ne "  ${Y}¿Deseas continuar de todas formas? (s/N): ${RESET}"
    read -r respuesta
    if [[ ! "$respuesta" =~ ^[sS]$ ]]; then
      echo -e "  ${DIM}Operación cancelada.${RESET}"
      exit 1
    fi
  fi
}

# ── Lógica de Operaciones ────────────────────────────────────

# 1. BUSCAR / INSTALAR
do_search() {
  local repo="$1"
  echo -e "${DIM}Escribe para buscar un paquete...${RESET}"

  case "$repo" in
  pacman)
    local pkg=$(echo "" | fzf --disabled --ansi --prompt="🔍 Buscar en Pacman: " \
      --bind 'change:reload(echo ""; pacman -Ss {q} 2>/dev/null | awk '"'"'/^\// {print $1} /^[a-zA-Z]/ {print $1}'"'"')' \
      --preview 'pacman -Si {1}')
    [[ -n "$pkg" ]] && sudo pacman -S $(echo "$pkg" | cut -d'/' -f2 | awk '{print $1}')
    ;;
  yay)
    local pkg=$(echo "" | fzf --disabled --ansi --prompt="🔍 Buscar en AUR (yay): " \
      --bind 'change:reload(echo ""; yay -Ss {q} 2>/dev/null | awk '"'"'/^\// {print $1} /^[a-zA-Z]/ {print $1}'"'"')' \
      --preview 'yay -Si {1}')
    [[ -n "$pkg" ]] && yay -S $(echo "$pkg" | cut -d'/' -f2 | awk '{print $1}')
    ;;
  homebrew)
    local pkg=$(echo "" | fzf --disabled --ansi --prompt="🔍 Buscar en Homebrew: " \
      --bind 'change:reload(echo ""; brew search {q} 2>/dev/null)' \
      --preview 'brew info {1}')
    [[ -n "$pkg" ]] && brew install "$pkg"
    ;;
  flatpak)
    local pkg=$(echo "" | fzf --disabled --ansi --prompt="🔍 Buscar en Flatpak: " \
      --bind 'change:reload(echo ""; flatpak search {q} 2>/dev/null | awk -F"\t" '"'"'NR>1 {print $2}'"'"')' \
      --preview 'flatpak info {1}')
    [[ -n "$pkg" ]] && flatpak install flathub "$pkg"
    ;;
  esac
}

# 2. ACTUALIZAR
do_update() {
  local repo="$1"
  run_timeshift

  echo -e "${C}🚀 Ejecutando actualización para ${repo}...${RESET}\n"
  case "$repo" in
  pacman) sudo pacman -Syu ;;
  yay) yay -Syu ;;
  homebrew) brew update && brew upgrade ;;
  flatpak) flatpak update ;;
  esac
}

# 3. DESINSTALAR
do_uninstall() {
  local repo="$1"

  case "$repo" in
  pacman)
    local pkgs=$(pacman -Qeq | xargs pacman -Qi | awk '/^(Nombre|Name)/ {printf "%s ", $3} /^(Tamaño de la instalación|Installed Size)/ {print $4, $5}' | sort -h -k2 -r | fzf --multi --prompt="🗑️  Eliminar de Pacman (Tab para seleccionar): " --preview 'pacman -Qi {1}' | awk '{print $1}')
    [[ -n "$pkgs" ]] && sudo pacman -Rns $pkgs
    ;;
  yay)
    local pkgs=$(yay -Qm | awk '{print $1}' | xargs pacman -Qi | awk '/^(Nombre|Name)/ {printf "%s ", $3} /^(Tamaño de la instalación|Installed Size)/ {print $4, $5}' | sort -h -k2 -r | fzf --multi --prompt="🗑️  Eliminar de AUR (Tab para seleccionar): " --preview 'yay -Qi {1}' | awk '{print $1}')
    [[ -n "$pkgs" ]] && yay -Rns $pkgs
    ;;
  homebrew)
    local pkgs=$(brew leaves | xargs -I {} sh -c 'echo -n "{} "; du -sh $(brew --cellar)/{} | awk "{print \$1}"' | sort -h -k2 -r | fzf --multi --prompt="🗑️  Eliminar de Homebrew: " --preview 'brew info {1}' | awk '{print $1}')
    [[ -n "$pkgs" ]] && echo "$pkgs" | xargs -r brew uninstall
    ;;
  flatpak)
    local pkgs=$(flatpak list --app --columns=application,size | fzf --multi --prompt="🗑️  Eliminar de Flatpak: " --preview 'flatpak info {1}' | awk '{print $1}')
    [[ -n "$pkgs" ]] && echo "$pkgs" | xargs -r flatpak uninstall
    ;;
  esac
}

# ── Loop Principal de Menús ──────────────────────────────────
while true; do
  print_header

  # Menú 1: Selección de Acción con fzf
  echo -e "  ${BOLD}${W}Selecciona una acción:${RESET}"
  action=$(echo -e "🔎 Buscar e Instalar\n🔄 Actualizar Repositorio\n🗑️  Desinstalar Paquetes\n❌ Salir" | fzf --prompt="Acción > " | awk '{print $2}')

  [[ -z "$action" || "$action" == "Salir" ]] && {
    echo -e "  ${DIM}Hasta luego.${RESET}\n"
    exit 0
  }

  # Menú 2: Selección de Repositorio con fzf
  print_header
  echo -e "  ${BOLD}${W}Selecciona el repositorio para [${C}${action}${W}]:${RESET}"
  repo=$(echo -e "📦 pacman\n📦 yay (AUR)\n📦 homebrew\n📦 flatpak\n🔙 Volver" | fzf --prompt="Repositorio > " | awk '{print $2}' | tr -d '()')

  [[ -z "$repo" || "$repo" == "Volver" ]] && continue

  print_header

  # Enrutar según la acción elegida
  case "$action" in
  Buscar) do_search "$repo" ;;
  Actualizar) do_update "$repo" ;;
  Desinstalar) do_uninstall "$repo" ;;
  esac

  # Esperar confirmación antes de refrescar (excepto si salimos limpios de fzf)
  echo ""
  echo -ne "  ${DIM}[Enter para volver al menú principal]${RESET}"
  read -r
done
