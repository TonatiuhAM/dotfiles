#!/bin/zsh
# =============================================================================
# ~/.zshrc - Configuración Interactiva de Zsh para macOS
# =============================================================================
# Autor: tonatiuham
# Última modificación: 28 Enero 2026
# Descripción: Configuración principal de zsh con organización modular
# =============================================================================

# =============================================================================
# 1. CONFIGURACIÓN INICIAL Y VARIABLES DE ENTORNO
# =============================================================================
# Editor y herramientas por defecto
export EDITOR="nvim"
export VISUAL="nvim"

# Configuración de Java
export JAVA_HOME=$(/usr/libexec/java_home -v 17)

# Configuración de PATH
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"
export PATH="/Users/tonatiuham/.local/bin:$PATH"

# =============================================================================
# 2. CONFIGURACIÓN DE ZSH Y HISTORIAL
# =============================================================================
# Configuración del historial
HISTSIZE=5000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE

# Opciones de historial para mejor experiencia
setopt appendhistory 
setopt share_history 
setopt hist_ignore_space 
setopt hist_ignore_all_dups 
setopt hist_save_no_dups 
setopt hist_ignore_dups 
setopt hist_find_no_dups

# Modo vi para línea de comandos
bindkey -v

# =============================================================================
# 3. OH-MY-ZSH Y TEMA
# =============================================================================
# Configuración de Oh-My-Zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins de Oh-My-Zsh
plugins=(git fzf)

# Carga de Oh-My-Zsh
source $ZSH/oh-my-zsh.sh

# =============================================================================
# 4. POWERLEVEL10K CONFIGURACIÓN
# =============================================================================
# Prompt instantáneo de Powerlevel10k (debe ir antes de otras configuraciones del prompt)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Configuración personalizada del prompt
typeset -g POWERLEVEL9K_PROMPT_PREFIX="  "
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Carga del archivo de configuración de Powerlevel10k
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# =============================================================================
# 5. PLUGINS Y EXTENSIONES DE ZSH
# =============================================================================
# Inicialización de Zinit para gestión avanzada de plugins
source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Plugins de mejora para zsh
zinit light zsh-users/zsh-syntax-highlighting  # Resaltado de sintaxis
zinit light zsh-users/zsh-completions          # Completaciones adicionales
zinit light zsh-users/zsh-autosuggestions      # Sugerencias automáticas

# =============================================================================
# 6. FUNCIONES PERSONALIZADAS
# =============================================================================
# Función: spf
# Propósito: Integración con Superfile para cambio de directorio automático
# Uso: spf [argumentos_de_superfile]
spf() {
    os=$(uname -s)

    # Linux
    if [[ "$os" == "Linux" ]]; then
        export SPF_LAST_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/superfile/lastdir"
    fi

    # macOS
    if [[ "$os" == "Darwin" ]]; then
        export SPF_LAST_DIR="$HOME/Library/Application Support/superfile/lastdir"
    fi

    command spf "$@"

    [ ! -f "$SPF_LAST_DIR" ] || {
        . "$SPF_LAST_DIR"
        rm -f -- "$SPF_LAST_DIR" > /dev/null
    }
}
# Función: scpkindle
# Propósito: Transferir archivos al Kindle vía SCP
# Uso: scpkindle <archivo_local> <>
scpkindle() {
    scp -P 2222 -r "$2" root@192.168.100."$1":"/mnt/us/libros/$3"
}

# Función: rc
# Propósito: Gestor unificado de archivos de configuración
# Uso: rc <programa> | rc help
rc() {
    case "$1" in
        # Configuraciones en home
        zsh)        nvim ~/.zshrc ;;
        tmux)       cd && nvim .tmux.conf ;;
        
        # Configuraciones en .config
        nvim)       nvim ~/.config/nvim ;;
        ghostty)    nvim ~/.config/ghostty/config ;;
        
        # Configuraciones con rutas específicas  
        aerospace)  nvim ~/.aerospace.toml ;;
        fastfetch)  nvim ~/.config/fastfetch/config.jsonc ;;
        superfile)  nvim ~/Library/Application\ Support/superfile/config.toml ;;
        
        # Ayuda y documentación
        --help|-h|help)
            echo "rc - Gestor de archivos de configuración"
            echo ""
            echo "Uso: rc <programa>"
            echo ""
            echo "Programas disponibles:"
            echo "  zsh        - Configuración de zsh (~/.zshrc)"
            echo "  tmux       - Configuración de tmux (~/.tmux.conf)"
            echo "  nvim       - Configuración de Neovim (~/.config/nvim)"
            echo "  aerospace  - Configuración de AeroSpace"
            echo "  ghostty    - Configuración de Ghostty"
            echo "  fastfetch  - Configuración de Fastfetch"
            echo "  superfile  - Configuración de Superfile"
            ;;
        
        # Manejo de errores para comandos no encontrados
        *)
            echo "❌ Error: Configuración '$1' no encontrada"
            echo "💡 Tip: Usa 'rc help' para ver programas disponibles"
            return 1
            ;;
    esac
}

function y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	rm -f -- "$tmp"
}

# =============================================================================
# 7. ALIASES - HERRAMIENTAS Y UTILIDADES GENERALES
# =============================================================================
# Docker y contenedores
alias dcu='docker-compose up --build -d'
alias dcd='docker-compose down'
alias ld='lazydocker'

# Git y control de versiones
alias lg='lazygit'

# Editores y herramientas de desarrollo
alias nv="nvim"

# Sistema y terminal
alias ff='fastfetch'
alias zshs='source ~/.zshrc'  # Recargar configuración de zsh
alias ls='lsd -lA'

# Zellij
alias zhelp='zellij -h'
alias zls='zellij list-sessions'

zdelete() {
  zellij delete-session "$1"
}

zattach() {
  zellij attach "$1"
}

zrename() {
  zellij action rename-session "$1"
}

# =============================================================================
# 8. ALIASES - CONEXIONES SSH Y SERVIDORES
# =============================================================================
# Servidores principales
alias elserver='ssh tona@100.81.159.65'
alias pve='ssh root@100.69.42.67'

kindle() {
  ssh root@192.168.100."$1" -p 2222
}

# =============================================================================
# 9. ALIASES - TMUX Y SESIONES DE TRABAJO
# =============================================================================
# Comandos generales de tmux
alias tl='tmux ls'
alias ta='tmux attach-session'

# =============================================================================
# 10. INTEGRACIONES EXTERNAS Y HERRAMIENTAS
# =============================================================================
# Homebrew - gestor de paquetes para macOS
eval "$(/opt/homebrew/bin/brew shellenv)"

# Ruby Version Manager con rbenv
eval "$(rbenv init - zsh)"

# Zoxide - navegación mejorada de directorios (sustituto de cd)
eval "$(zoxide init zsh)"

# Cargo - gestor de paquetes de Rust
. "$HOME/.cargo/env"

# =============================================================================
# 11. CONFIGURACIÓN FINAL Y LIMPIEZA
# =============================================================================
# Suprime el mensaje de bienvenida del sistema al abrir terminal
touch ~/.hushlogin

# =============================================================================
# 12. FASTFETCH - INFORMACIÓN DEL SISTEMA
# =============================================================================
# Mostrar información del sistema al iniciar (colocado al final para mejor performance)
fastfetch
