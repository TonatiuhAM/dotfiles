#!/usr/bin/env bash
#
# setup-zsh.sh — Instala todo lo que las configs de zsh de este repo necesitan
# y que NO viaja dentro de los dotfiles (por diseño: son frameworks/fuentes de
# terceros, no configuración propia).
#
# Por qué existe: install.sh solo crea symlinks. .zshrc espera encontrar Oh My
# Zsh + el tema Powerlevel10k + varios plugins ya clonados en disco, y la
# terminal (kitty/alacritty) espera una fuente Nerd Font instalada para poder
# dibujar los íconos del prompt. Ninguna de esas tres cosas es un paquete de
# pacman/dnf en este setup (se instalaron a mano vía git clone / descarga de
# fuente), así que pegar solo los dotfiles nunca es suficiente.
#
# Qué hace:
#   1. Instala zsh/git/curl/unzip si faltan.
#   2. Clona (o actualiza si ya existen) Oh My Zsh, powerlevel10k y los
#      plugins zsh-autosuggestions / zsh-syntax-highlighting / zsh-vi-mode en
#      las rutas exactas que .zprofile/.zshrc esperan.
#   3. Descarga e instala las fuentes Nerd Font que usan kitty/alacritty
#      (Maple Mono NF y JetBrainsMono Nerd Font) en ~/.local/share/fonts.
#   4. Deja zsh como shell de login (chsh), con confirmación explícita.
#
# Uso:
#   ./setup-zsh.sh                # instala todo, pregunta antes de chsh
#   ./setup-zsh.sh --yes          # no interactivo, confirma todo automático
#   ./setup-zsh.sh --dry-run      # muestra qué haría, sin tocar nada
#   ./setup-zsh.sh --skip-shell   # no toca el shell de login
#   ./setup-zsh.sh --skip-fonts   # no descarga fuentes

set -uo pipefail

# ---------------------------------------------------------------------------
# Configuración / rutas (mismas convenciones que .zprofile)
# ---------------------------------------------------------------------------

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"
FONTS_DIR="$HOME/.local/share/fonts"
ZSH_DIR="$XDG_DATA_HOME/oh-my-zsh"
ZSH_CUSTOM="$ZSH_DIR/custom"
LOG_FILE="$DOTFILES_DIR/setup-zsh.log"

OMZ_REPO="https://github.com/ohmyzsh/ohmyzsh.git"
declare -A PLUGIN_REPOS=(
    [zsh-autosuggestions]="https://github.com/zsh-users/zsh-autosuggestions"
    [zsh-syntax-highlighting]="https://github.com/zsh-users/zsh-syntax-highlighting.git"
    [zsh-vi-mode]="https://github.com/jeffreytse/zsh-vi-mode"
)
THEME_REPO="https://github.com/romkatv/powerlevel10k.git"

DRY_RUN=false
ASSUME_YES=false
SKIP_SHELL=false
SKIP_FONTS=false
for arg in "$@"; do
    case "$arg" in
        --dry-run)    DRY_RUN=true ;;
        --yes)        ASSUME_YES=true ;;
        --skip-shell) SKIP_SHELL=true ;;
        --skip-fonts) SKIP_FONTS=true ;;
        *) echo "Argumento desconocido: $arg" >&2; exit 2 ;;
    esac
done

FAILED=0

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
# 1. Paquetes base: zsh, git, curl, unzip
# ---------------------------------------------------------------------------

ensure_packages() {
    local missing=() pkg
    for pkg in zsh git curl unzip; do
        command -v "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
    done

    if [[ ${#missing[@]} -eq 0 ]]; then
        ok "zsh, git, curl y unzip ya están instalados."
        return
    fi

    warn "Faltan: ${missing[*]}. Intentando instalarlos..."
    if $DRY_RUN; then
        info "[dry-run] se instalarían: ${missing[*]}"
        return
    fi

    if command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y "${missing[@]}" || die "No se pudieron instalar: ${missing[*]} (dnf)."
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -S --noconfirm "${missing[@]}" || die "No se pudieron instalar: ${missing[*]} (pacman)."
    elif command -v apt >/dev/null 2>&1; then
        sudo apt update && sudo apt install -y "${missing[@]}" || die "No se pudieron instalar: ${missing[*]} (apt)."
    else
        die "No se encontró un gestor de paquetes soportado (dnf/pacman/apt). Instala manualmente: ${missing[*]}."
    fi
    ok "Paquetes base instalados."
}

# ---------------------------------------------------------------------------
# 2. Oh My Zsh + tema + plugins (git clone directo, sin correr el instalador
#    oficial de OMZ para no tocar .zshrc ni el shell por su cuenta).
# ---------------------------------------------------------------------------

clone_or_update() {
    local repo="$1" dest="$2" label="$3"

    if [[ -d "$dest/.git" ]]; then
        if $DRY_RUN; then
            info "[dry-run] git -C '$dest' pull ($label)"
            return
        fi
        if git -C "$dest" pull --ff-only >>"$LOG_FILE" 2>&1; then
            ok "$label actualizado ($dest)."
        else
            err "No se pudo actualizar $label en $dest (revisa cambios locales/conflictos)."
            FAILED=1
        fi
        return
    fi

    if [[ -e "$dest" ]]; then
        warn "$dest ya existe pero no es un repo git; se deja tal cual (revísalo a mano si $label no carga)."
        return
    fi

    if $DRY_RUN; then
        info "[dry-run] git clone --depth=1 '$repo' '$dest'  ($label)"
        return
    fi

    mkdir -p "$(dirname "$dest")"
    if git clone --depth=1 "$repo" "$dest" >>"$LOG_FILE" 2>&1; then
        ok "$label clonado en $dest."
    else
        err "No se pudo clonar $label desde $repo."
        FAILED=1
    fi
}

install_omz_stack() {
    info "Instalando Oh My Zsh + powerlevel10k + plugins en $ZSH_DIR ..."
    clone_or_update "$OMZ_REPO" "$ZSH_DIR" "Oh My Zsh"
    clone_or_update "$THEME_REPO" "$ZSH_CUSTOM/themes/powerlevel10k" "powerlevel10k"

    local name
    for name in "${!PLUGIN_REPOS[@]}"; do
        clone_or_update "${PLUGIN_REPOS[$name]}" "$ZSH_CUSTOM/plugins/$name" "$name"
    done
}

# ---------------------------------------------------------------------------
# 3. Fuentes Nerd Font que usan kitty/alacritty (viven en ~/.local/share/fonts,
#    que no forma parte del paquete de stow porque no cuelga de ~/.config).
# ---------------------------------------------------------------------------

# Busca en la última release de un repo de GitHub el asset cuyo nombre haga
# match exacto y devuelve su browser_download_url.
latest_release_asset_url() {
    local repo="$1" asset_name="$2"
    curl -fsSL "https://api.github.com/repos/$repo/releases/latest" \
        | grep -oE '"browser_download_url": *"[^"]*"' \
        | sed -E 's/.*"(https:[^"]*)"/\1/' \
        | grep -F "/$asset_name"
}

install_font_zip() {
    local repo="$1" asset_name="$2" dest_dir="$3" label="$4"

    if [[ -d "$dest_dir" ]] && find "$dest_dir" -iname '*.ttf' -o -iname '*.otf' 2>/dev/null | grep -q .; then
        ok "$label ya está instalada en $dest_dir."
        return
    fi

    if $DRY_RUN; then
        info "[dry-run] se descargaría $asset_name de $repo y se instalaría en $dest_dir"
        return
    fi

    local url
    url="$(latest_release_asset_url "$repo" "$asset_name")"
    if [[ -z "$url" ]]; then
        err "No se encontró el asset '$asset_name' en la última release de $repo (¿sin internet?)."
        FAILED=1
        return
    fi

    local tmp_zip
    tmp_zip="$(mktemp --suffix=.zip)"
    if ! curl -fsSL "$url" -o "$tmp_zip"; then
        err "No se pudo descargar $label desde $url."
        rm -f "$tmp_zip"
        FAILED=1
        return
    fi

    mkdir -p "$dest_dir"
    if unzip -oq "$tmp_zip" -d "$dest_dir" >>"$LOG_FILE" 2>&1; then
        ok "$label instalada en $dest_dir."
    else
        err "No se pudo descomprimir $label en $dest_dir."
        FAILED=1
    fi
    rm -f "$tmp_zip"
}

install_fonts() {
    if $SKIP_FONTS; then
        info "Se omite instalación de fuentes (--skip-fonts)."
        return
    fi

    info "Instalando fuentes Nerd Font (Maple Mono NF + JetBrainsMono)..."
    install_font_zip "subframe7536/maple-font" "MapleMono-NF-unhinted.zip" \
        "$FONTS_DIR/MapleMono" "Maple Mono NF"
    install_font_zip "ryanoasis/nerd-fonts" "JetBrainsMono.zip" \
        "$FONTS_DIR/JetBrainsMonoNerdFont" "JetBrainsMono Nerd Font"

    if $DRY_RUN; then
        info "[dry-run] se correría fc-cache para refrescar la caché de fuentes."
        return
    fi
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f >>"$LOG_FILE" 2>&1
        ok "Caché de fuentes actualizada (fc-cache)."
    else
        warn "fc-cache no está disponible; instala fontconfig o corre fc-cache manualmente."
    fi
}

# ---------------------------------------------------------------------------
# 4. Dejar zsh como shell de login
# ---------------------------------------------------------------------------

set_default_shell() {
    if $SKIP_SHELL; then
        info "Se omite el cambio de shell por defecto (--skip-shell)."
        return
    fi

    local zsh_path current_shell
    zsh_path="$(command -v zsh || true)"
    if [[ -z "$zsh_path" ]]; then
        err "No se encontró el binario de zsh; no se puede configurar como shell por defecto."
        FAILED=1
        return
    fi

    current_shell="$(getent passwd "$USER" 2>/dev/null | cut -d: -f7)"
    if [[ "$current_shell" == "$zsh_path" ]]; then
        ok "zsh ya es el shell de login de $USER."
        return
    fi

    if ! grep -qxF "$zsh_path" /etc/shells 2>/dev/null; then
        warn "$zsh_path no está listado en /etc/shells; chsh podría rechazarlo."
    fi

    if $DRY_RUN; then
        info "[dry-run] chsh -s '$zsh_path' '$USER'"
        return
    fi

    if ! $ASSUME_YES; then
        read -r -p "¿Cambiar el shell de login de $USER a $zsh_path ahora? [Y/n] " reply
        if [[ "$reply" =~ ^[Nn] ]]; then
            warn "Se dejó el shell de login sin cambiar. Puedes hacerlo luego con: chsh -s $zsh_path"
            return
        fi
    fi

    if chsh -s "$zsh_path" "$USER"; then
        ok "Shell de login cambiado a $zsh_path (aplica en la próxima sesión de login)."
    else
        err "chsh falló. Cambia el shell manualmente con: chsh -s $zsh_path"
        FAILED=1
    fi
}

# ---------------------------------------------------------------------------
# Resumen
# ---------------------------------------------------------------------------

print_summary() {
    echo
    log "${C_BOLD}========== RESUMEN ==========${C_RESET}"
    if [[ "$FAILED" -eq 0 ]]; then
        ok "Setup de zsh completado correctamente."
        info "Corre './install.sh' si aún no lo has hecho (crea los symlinks de .zshrc/.zprofile/etc)."
        info "Abre una sesión nueva (o 'exec zsh') para ver el prompt y las fuentes aplicadas."
    else
        err "El setup terminó con errores. Revisa el resumen y $LOG_FILE."
    fi
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

main() {
    info "XDG_DATA_HOME: $XDG_DATA_HOME"
    info "Oh My Zsh dir: $ZSH_DIR"
    $DRY_RUN && warn "Modo --dry-run: no se modificará nada en el sistema."

    ensure_packages
    install_omz_stack
    install_fonts
    set_default_shell
    print_summary

    exit "$FAILED"
}

main
