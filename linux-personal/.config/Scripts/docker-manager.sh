#!/usr/bin/env bash
# ============================================================
#  dk — Docker Compose interactive menu
#  Instalar: chmod +x dk.sh && sudo mv dk.sh /usr/local/bin/dk
# ============================================================

# ── Colores ──────────────────────────────────────────────────
R='\033[0;31m'      # rojo
G='\033[0;32m'      # verde
Y='\033[1;33m'      # amarillo
B='\033[0;34m'      # azul
C='\033[0;36m'      # cyan
M='\033[0;35m'      # magenta
W='\033[1;37m'      # blanco brillante
DIM='\033[2m'       # tenue
BOLD='\033[1m'
RESET='\033[0m'

# ── Detectar comando docker compose ──────────────────────────
if docker compose version &>/dev/null 2>&1; then
  DC="docker compose"
elif command -v docker-compose &>/dev/null; then
  DC="docker-compose"
else
  echo -e "${R}Error:${RESET} No se encontró 'docker compose' ni 'docker-compose'."
  exit 1
fi

# ── Detectar archivo compose ─────────────────────────────────
COMPOSE_FILE=""
for f in docker-compose.yml docker-compose.yaml compose.yml compose.yaml; do
  if [[ -f "$f" ]]; then
    COMPOSE_FILE="$f"
    break
  fi
done

if [[ -z "$COMPOSE_FILE" ]]; then
  echo -e "${R}Error:${RESET} No se encontró ningún archivo docker-compose en el directorio actual."
  echo -e "${DIM}  Ejecuta dk desde la carpeta donde está tu docker-compose.yml${RESET}"
  exit 1
fi

DC="$DC -f $COMPOSE_FILE"

# ── ps con formato de lista y colores ────────────────────────
cmd_ps() {
  echo ""
  echo -e "${BOLD}${C}  Contenedores:${RESET}"
  echo -e "${DIM}  ─────────────────────────────────────────${RESET}"

  # Obtener lista: nombre | estado | puertos
  local lines
  lines=$($DC ps --format "{{.Name}}|{{.State}}|{{.Ports}}" 2>/dev/null) || \
  lines=$($DC ps --format "table {{.Name}}\t{{.State}}\t{{.Ports}}" 2>/dev/null | tail -n +2 | awk '{print $1"|"$2"|"$3}')

  if [[ -z "$lines" ]]; then
    echo -e "  ${DIM}(ningún contenedor activo)${RESET}"
    echo ""
    return
  fi

  while IFS='|' read -r name state ports; do
    [[ -z "$name" ]] && continue

    # Color según estado
    local color="$DIM"
    local icon="○"
    case "$state" in
      running)  color="$G"; icon="●" ;;
      exited)   color="$R"; icon="✕" ;;
      paused)   color="$Y"; icon="⏸" ;;
      created)  color="$B"; icon="+" ;;
      restarting) color="$M"; icon="↺" ;;
    esac

    printf "  ${color}${icon}${RESET}  ${W}%-35s${RESET}  ${color}%-12s${RESET}  ${DIM}%s${RESET}\n" \
      "$name" "$state" "$ports"
  done <<< "$lines"

  echo ""
}

# ── Ejecutar comando sobre servicios ─────────────────────────
run_cmd() {
  local action="$1"
  shift
  local services=("$@")   # puede estar vacío

  case "$action" in
    up)
      if [[ ${#services[@]} -gt 0 ]]; then
        echo -e "\n${G}▶ Iniciando:${RESET} ${services[*]}\n"
        $DC up -d "${services[@]}"
      else
        echo -e "\n${G}▶ Iniciando todos los servicios...${RESET}\n"
        $DC up -d
      fi
      ;;
    down)
      if [[ ${#services[@]} -gt 0 ]]; then
        echo -e "\n${Y}■ Deteniendo y eliminando:${RESET} ${services[*]}\n"
        $DC stop "${services[@]}"
        $DC rm -f "${services[@]}"
      else
        echo -e "\n${Y}■ Deteniendo todos los servicios...${RESET}\n"
        $DC down
      fi
      ;;
    build)
      if [[ ${#services[@]} -gt 0 ]]; then
        echo -e "\n${C}🔨 Build + up:${RESET} ${services[*]}\n"
        $DC up -d --build "${services[@]}"
      else
        echo -e "\n${C}🔨 Build + up de todos...${RESET}\n"
        $DC up -d --build
      fi
      ;;
    logs)
      if [[ ${#services[@]} -gt 0 ]]; then
        echo -e "\n${M}📄 Logs de:${RESET} ${services[*]}\n"
        $DC logs -f "${services[@]}"
      else
        echo -e "\n${M}📄 Logs de todos...${RESET}\n"
        $DC logs -f
      fi
      ;;
  esac
}

# ── Menú ─────────────────────────────────────────────────────
show_menu() {
  clear
  echo ""
  echo -e "  ${BOLD}${C}╔══════════════════════════════╗${RESET}"
  echo -e "  ${BOLD}${C}║${RESET}  ${W}${BOLD}dk${RESET} — Docker Compose menu    ${BOLD}${C}║${RESET}"
  echo -e "  ${BOLD}${C}╚══════════════════════════════╝${RESET}"
  echo -e "  ${DIM}archivo: ${COMPOSE_FILE}${RESET}"
  echo ""
  echo -e "  ${G}u${RESET}  ${DIM}·${RESET}  up          ${DIM}inicia contenedores${RESET}"
  echo -e "  ${Y}d${RESET}  ${DIM}·${RESET}  down        ${DIM}detiene y elimina contenedores${RESET}"
  echo -e "  ${C}b${RESET}  ${DIM}·${RESET}  build       ${DIM}rebuild + up${RESET}"
  echo -e "  ${M}l${RESET}  ${DIM}·${RESET}  logs        ${DIM}ver logs en vivo${RESET}"
  echo -e "  ${W}ps${RESET} ${DIM}·${RESET}  status      ${DIM}lista de contenedores${RESET}"
  echo -e "  ${R}q${RESET}  ${DIM}·${RESET}  quit        ${DIM}salir${RESET}"
  echo ""
  echo -e "  ${DIM}Puedes agregar nombres de servicio después del comando:${RESET}"
  echo -e "  ${DIM}  Ej: ${RESET}${W}b api worker${DIM}  →  rebuild solo de 'api' y 'worker'${RESET}"
  echo ""
  echo -ne "  ${BOLD}→ ${RESET}"
}

# ── Loop principal ────────────────────────────────────────────
while true; do
  show_menu
  read -r input

  # Parsear: primer token = comando, el resto = servicios
  read -r cmd rest <<< "$input"
  IFS=' ' read -r -a svc_args <<< "$rest"

  echo ""
  case "$cmd" in
    u|up)
      run_cmd up "${svc_args[@]}"
      ;;
    d|down)
      run_cmd down "${svc_args[@]}"
      ;;
    b|build)
      run_cmd build "${svc_args[@]}"
      ;;
    l|logs)
      run_cmd logs "${svc_args[@]}"
      ;;
    ps|status)
      cmd_ps
      ;;
    q|quit|exit)
      echo -e "  ${DIM}Hasta luego.${RESET}\n"
      exit 0
      ;;
    "")
      # Enter vacío: refrescar menú
      ;;
    *)
      echo -e "  ${R}Comando no reconocido:${RESET} '$cmd'"
      sleep 1
      ;;
  esac

  # Pausar antes de volver al menú (excepto logs que bloquea)
  case "$cmd" in
    l|logs) ;;  # logs ya consume el proceso, al salir con Ctrl+C vuelve al loop
    q|quit|exit) ;;
    *)
      echo ""
      echo -ne "  ${DIM}[Enter para volver al menú]${RESET}"
      read -r
      ;;
  esac
done
