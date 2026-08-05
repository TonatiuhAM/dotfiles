#!/usr/bin/env bash
#
# install.sh — Instala (via GNU Stow) los dotfiles de linux-personal/ en $HOME.
#
# Qué hace:
#   1. Verifica/instala GNU Stow con el gestor de paquetes disponible (dnf, pacman, apt).
#   2. Le pide a stow (en modo --simulate) que diga exactamente qué rutas del host
#      chocan con el paquete, y solo esas rutas se respaldan (nunca se borran sin
#      respaldo). Esto respeta el "folding" real de stow: si algo como
#      ~/.config/git ya es una mezcla de symlinks propios + archivos sueltos que no
#      pertenecen al paquete, esos archivos sueltos NO se tocan.
#   3. Se asegura de que ~/.config exista como directorio real (no symlink) para que
#      stow pueda descender y crear un symlink por aplicación en vez de symlinkear
#      todo ~/.config de un jalón la primera vez que se instala en un sistema nuevo.
#   4. Ejecuta stow de verdad y confirma con otra simulación que ya no queda ningún
#      conflicto pendiente.
#   5. Imprime un resumen final y termina con código de salida != 0 si algo falló.
#
# Uso:
#   ./install.sh            # instala todo
#   ./install.sh --dry-run  # muestra qué haría, sin tocar nada

set -uo pipefail

# ---------------------------------------------------------------------------
# Configuración / rutas
# ---------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE="linux-personal"
PACKAGE_DIR="$DOTFILES_DIR/$PACKAGE"
TARGET_DIR="$HOME"
TIMESTAMP="$(date +%Y%m%d-%H%M%S)"
BACKUP_DIR="$HOME/.dotfiles-backup/$TIMESTAMP"
LOG_FILE="$DOTFILES_DIR/install.log"
MAX_BACKUP_ROUNDS=5

DRY_RUN=false
[[ "${1:-}" == "--dry-run" ]] && DRY_RUN=true

FAILED=0
BACKED_UP=()

# ---------------------------------------------------------------------------
# Utilidades de salida
# ---------------------------------------------------------------------------

C_RESET='\033[0m'; C_RED='\033[0;31m'; C_GREEN='\033[0;32m'
C_YELLOW='\033[0;33m'; C_BLUE='\033[0;34m'; C_BOLD='\033[1m'

log()  { printf '%b\n' "$*" | tee -a "$LOG_FILE" >&2; }
info() { log "${C_BLUE}[INFO]${C_RESET} $*"; }
ok()   { log "${C_GREEN}[ OK ]${C_RESET} $*"; }
warn() { log "${C_YELLOW}[WARN]${C_RESET} $*"; }
err()  { log "${C_RED}[FAIL]${C_RESET} $*"; }

die() {
    err "$*"
    err "Instalación abortada. Revisa el log en: $LOG_FILE"
    exit 1
}

trap 'err "Error inesperado en línea $LINENO ejecutando: $BASH_COMMAND"; exit 1' ERR

: > "$LOG_FILE"

# ---------------------------------------------------------------------------
# 1. Verificar / instalar GNU Stow
# ---------------------------------------------------------------------------

ensure_stow() {
    if command -v stow >/dev/null 2>&1; then
        ok "GNU Stow ya está instalado ($(stow --version | head -1))."
        return
    fi

    warn "GNU Stow no está instalado. Intentando instalarlo..."
    if $DRY_RUN; then
        info "[dry-run] se instalaría 'stow' con el gestor de paquetes detectado."
        return
    fi

    if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y stow || die "No se pudo instalar 'stow' con dnf."
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm stow || die "No se pudo instalar 'stow' con pacman."
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y stow || die "No se pudo instalar 'stow' con apt."
    else
        die "No se encontró un gestor de paquetes soportado (dnf/pacman/apt). Instala 'stow' manualmente."
    fi
    ok "GNU Stow instalado correctamente."
}

# ---------------------------------------------------------------------------
# 2. Preparar el target: ~/.config debe existir como directorio real, si no
#    stow symlinkearía todo ~/.config de un jalón la primera vez (folding),
#    en vez de un symlink por aplicación.
# ---------------------------------------------------------------------------

prepare_target() {
    if [[ -L "$TARGET_DIR/.config" ]]; then
        warn "$TARGET_DIR/.config ya es un symlink ($(readlink "$TARGET_DIR/.config")). Se respaldará y se recreará como directorio real."
        move_to_backup "$TARGET_DIR/.config" ".config"
    fi

    if $DRY_RUN; then
        info "[dry-run] se crearía $TARGET_DIR/.config si no existe."
    else
        mkdir -p "$TARGET_DIR/.config"
    fi
}

# ---------------------------------------------------------------------------
# 3. Detectar conflictos reales preguntándole a stow (--simulate) y
#    respaldar exactamente esas rutas, ni una más.
# ---------------------------------------------------------------------------

# Corre stow en modo simulación y devuelve su salida combinada (stdout+stderr).
simulate_stow() {
    stow --simulate --dir="$DOTFILES_DIR" --target="$TARGET_DIR" "$PACKAGE" 2>&1
}

# Extrae, de la salida de stow, las rutas relativas a $TARGET_DIR que están
# en conflicto. Stow reporta dos formas de conflicto:
#   * cannot stow <src> over existing target <path> since neither a link...
#   * existing target is not owned by stow: <path>
parse_conflict_paths() {
    local output="$1"
    printf '%s\n' "$output" | grep -E '^\s*\* ' | while IFS= read -r line; do
        if [[ "$line" =~ over\ existing\ target\ (.+)\ since\ neither\ a\ link ]]; then
            printf '%s\n' "${BASH_REMATCH[1]}"
        elif [[ "$line" =~ existing\ target\ is\ not\ owned\ by\ stow:\ (.+)$ ]]; then
            printf '%s\n' "${BASH_REMATCH[1]}"
        fi
    done | sed 's/[[:space:]]*$//' | sort -u
}

resolve_conflicts() {
    info "Preguntándole a stow qué rutas de \$HOME chocan con el paquete..."

    local round=1 output rc paths path
    while (( round <= MAX_BACKUP_ROUNDS )); do
        output="$(simulate_stow)"; rc=$?

        if [[ $rc -eq 0 ]]; then
            [[ $round -eq 1 ]] && info "No hay conflictos: nada que respaldar."
            return
        fi

        paths="$(parse_conflict_paths "$output")"
        if [[ -z "$paths" ]]; then
            err "stow reportó un problema que no se pudo interpretar automáticamente:"
            printf '%s\n' "$output" | tee -a "$LOG_FILE" >&2
            FAILED=1
            return
        fi

        while IFS= read -r path; do
            [[ -z "$path" ]] && continue
            warn "Conflicto detectado en \$HOME/$path, se moverá a backup."
            move_to_backup "$TARGET_DIR/$path" "$path"
        done <<< "$paths"

        (( round++ ))
    done

    warn "Se alcanzó el máximo de $MAX_BACKUP_ROUNDS rondas de backup; volviendo a revisar por última vez."
}

move_to_backup() {
    local target="$1" leaf="$2" dest_dir dest

    [[ -e "$target" || -L "$target" ]] || return 0

    dest="$BACKUP_DIR/$leaf"
    dest_dir="$(dirname "$dest")"

    if $DRY_RUN; then
        info "[dry-run] mv '$target' -> '$dest'"
        BACKED_UP+=("$leaf")
        return
    fi

    mkdir -p "$dest_dir"
    if mv "$target" "$dest"; then
        ok "Backup: $leaf -> $dest"
        BACKED_UP+=("$leaf")
    else
        err "No se pudo mover $target a backup."
        FAILED=1
    fi
}

# ---------------------------------------------------------------------------
# 4. Ejecutar stow de verdad
# ---------------------------------------------------------------------------

run_stow() {
    info "Ejecutando stow para el paquete '$PACKAGE'..."
    if $DRY_RUN && [[ ${#BACKED_UP[@]} -gt 0 ]]; then
        warn "En --dry-run los backups no se ejecutan de verdad, así que esta simulación de"
        warn "stow puede seguir mostrando los mismos conflictos listados arriba; en una"
        warn "corrida real ya estarían resueltos antes de llegar a este paso."
    fi

    local stow_args=(-v --dir="$DOTFILES_DIR" --target="$TARGET_DIR" "$PACKAGE")
    $DRY_RUN && stow_args=(--simulate "${stow_args[@]}")

    if stow "${stow_args[@]}" >>"$LOG_FILE" 2>&1; then
        ok "stow terminó sin errores."
    else
        err "stow reportó errores. Detalle:"
        tail -n 20 "$LOG_FILE" | while IFS= read -r line; do err "  $line"; done
        FAILED=1
    fi
}

# ---------------------------------------------------------------------------
# 5. Verificación final: si stow ya no reporta ningún conflicto al simular
#    de nuevo, la instalación quedó consistente.
# ---------------------------------------------------------------------------

verify_links() {
    $DRY_RUN && { info "[dry-run] se omite verificación final."; return; }
    if [[ "$FAILED" -ne 0 ]]; then
        warn "Se omite la verificación final: stow ya reportó errores arriba."
        return
    fi

    info "Verificando que no queden conflictos pendientes..."
    local output rc
    output="$(simulate_stow)"; rc=$?

    if [[ $rc -ne 0 ]]; then
        err "Todavía hay conflictos después de instalar:"
        printf '%s\n' "$output" | grep -E '^\s*\* ' | while IFS= read -r line; do err "  $line"; done
        FAILED=1
    else
        ok "Verificación OK: stow no reporta conflictos pendientes."
    fi
}

# ---------------------------------------------------------------------------
# 6. Resumen
# ---------------------------------------------------------------------------

print_summary() {
    echo
    log "${C_BOLD}========== RESUMEN ==========${C_RESET}"

    if [[ ${#BACKED_UP[@]} -gt 0 ]]; then
        log "${C_YELLOW}Rutas respaldadas (${#BACKED_UP[@]}):${C_RESET}"
        printf '  - %s\n' "${BACKED_UP[@]}" | tee -a "$LOG_FILE" >&2
        log "  Backup en: $BACKUP_DIR"
    else
        log "No hubo configuraciones existentes que respaldar."
    fi

    echo
    if [[ "$FAILED" -eq 0 ]]; then
        ok "Instalación completada correctamente."
    else
        err "La instalación terminó con errores. Revisa el resumen y $LOG_FILE."
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    [[ -d "$PACKAGE_DIR" ]] || die "No se encontró el paquete '$PACKAGE' en $DOTFILES_DIR."

    info "Dotfiles dir: $DOTFILES_DIR"
    info "Target dir:   $TARGET_DIR"
    $DRY_RUN && warn "Modo --dry-run: no se modificará nada en el sistema."

    ensure_stow
    prepare_target
    resolve_conflicts
    run_stow
    verify_links
    print_summary

    exit "$FAILED"
}

main "$@"
