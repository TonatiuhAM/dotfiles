# =======================================================================================
# 1. Instant Prompt de Powerlevel10k
# =======================================================================================
typeset -g POWERLEVEL9K_INSTANT_PROMPT=off

# DEBE ir estrictamente en la primera línea ejecutable, antes de cualquier salida a stdout/stderr.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# =======================================================================================
# 2. Entorno, PATH y Homebrew
# =======================================================================================
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

export PATH="$CARGO_HOME/bin:$BUN_INSTALL/bin:$HOME/.opencode/bin:$HOME/bin:$HOME/.local/bin:/opt/cuda/bin:$PATH"

# Variables de entorno adicionales para scripts y herramientas
export desktop="$HOME/.local/share/applications"
export RIPGREP_CONFIG_PATH="$HOME/.config/ripgrep/config"

# =======================================================================================
# 3. Comportamiento del Shell y Teclado
# =======================================================================================
setopt AUTOCD
setopt NOBEEP
setopt NUMERIC_GLOB_SORT

# Asegurar que Alt + . inserte el último argumento
bindkey '\e.' insert-last-word
bindkey '^[.' insert-last-word

# =======================================================================================
# 4. Oh My Zsh, Tema y Plugins
# =======================================================================================
export ZSH="${ZSH:-$HOME/.local/share/oh-my-zsh}"
ZSH_THEME="powerlevel10k/powerlevel10k"

# Orden óptimo: complementos base primero, vi-mode penúltimo y el resaltador estrictamente al final
plugins=(
    git
    zsh-autosuggestions
    zsh-vi-mode
    fast-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"

# =======================================================================================
# 5. Inicialización de Integraciones y Temas
# =======================================================================================
# Archivo de configuración de Powerlevel10k
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

# Salto inteligente de directorios con zoxide
eval "$(zoxide init zsh)"

# Autocompletado de Bun
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# Desactiva el fondo resaltado para directorios world-writable (ow) y sticky world-writable (tw)
export LS_COLORS="$(dircolors -p | grep -v -E '^OW|^TW' | dircolors - | sed -e 's/LS_COLORS=//' -e 's/;$//')"

# =======================================================================================
# 6. Funciones y Hooks de ZLE
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

autoload -Uz edit-command-line
zle -N edit-command-line

# zsh-vi-mode resetea los keybindings después de inicializarse; este hook preserva los atajos
function zvm_after_init() {
    bindkey '^f' _yazi_zle
    bindkey '^e' edit-command-line
    bindkey -M vicmd '^e' edit-command-line
}

# =======================================================================================
# 7. Alias
# =======================================================================================
alias vim='nvim'
alias v='nvim'
alias ll='lsd -lagh --group-dirs first --header'

# Herramientas TUI y scripts
alias t='$XDG_CONFIG_HOME/Scripts/tmux-sessionizer.sh'
alias lssh='lazyssh'
alias lg='lazygit'
alias ld='lazydocker'
alias dk='$XDG_CONFIG_HOME/Scripts/docker-manager.sh'
alias login-skip='$XDG_CONFIG_HOME/Scripts/login-skip.sh'
alias claudeop='touch ~/.config/claude/notify-on && claude --dangerously-skip-permissions'

# Recarga rápida de shell
alias zshsource='exec zsh'

# =======================================================================================
# 8. Comando de bienvenida interactivo (siempre al puro final)
# =======================================================================================
fastfetch
source ~/.config/fzf/catppuccin-fzf-mocha.sh
