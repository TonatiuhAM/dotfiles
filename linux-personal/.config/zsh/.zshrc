# 1. Ejecutar el comando visual (Fastfetch) al abrir la terminal
fastfetch

# =======================================================================================
# Comportamiento del Shell
# =======================================================================================
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# 2. Instant Prompt de P10K (Siempre arriba)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 3. Configuración de Oh My Zsh y Tema
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-vi-mode
)
# Carga Oh My Zsh usando la variable que definimos en el perfil
source $ZSH/oh-my-zsh.sh

# 4. Inicialización de herramientas interactivas
eval "$(zoxide init zsh)"

# Cargar P10K desde su nueva ubicación XDG
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

# Completions de Bun (con su nueva ruta XDG)
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# =======================================================================================
# 5. Funciones y Alias
# =======================================================================================
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

function _yazi_zle() {
    y
    zle reset-prompt
}
zle -N _yazi_zle

# zsh-vi-mode resetea los keybindings después de .zshrc — se usa su hook para no perder Ctrl+F
autoload -Uz edit-command-line
zle -N edit-command-line

function zvm_after_init() {
    bindkey '^f' _yazi_zle
    bindkey '^e' edit-command-line
    bindkey -M vicmd '^e' edit-command-line
}

# Alias generales
alias vim='nvim'
alias ls='lsd -lA'
alias open='thunar . & disown'

# Herramientas TUI y Scripts de administración
alias lssh='lazyssh'
alias lg='lazygit'
alias ld='lazydocker'
alias dk='$XDG_CONFIG_HOME/Scripts/docker-manager.sh'
alias sunshine-start='$XDG_CONFIG_HOME/Scripts/sunshine-start.sh'

# Reload del shell
alias zshsource='exec zsh'

# Actualizaciones del sistema con respaldo automático en Timeshift
alias apps="$XDG_CONFIG_HOME/Scripts/sysman.sh"
alias pacupdate='sudo timeshift --create --comments "pre-update" --tags D && sudo pacman -Syu'
alias yayupdate='sudo timeshift --create --comments "pre-update" --tags D && yay -Syu'
