fastfetch

# 1. Primero el Instant Prompt de P10K (Siempre arriba)
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# 2. Definir variables base (Bun, Cargo, etc.) ANTES de usarlas en el PATH
export ZSH="$HOME/.oh-my-zsh"
export BUN_INSTALL="$HOME/.bun"
export EDITOR='nvim'
export VISUAL='nvim'

# 3. Configurar el PATH (Una sola vez de forma limpia)
# Agregamos todo: Cargo, Bun, Opencode y carpetas locales
export PATH="$HOME/.cargo/bin:$BUN_INSTALL/bin:$HOME/.opencode/bin:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:$PATH"

# 4. Configuración de Oh My Zsh y Tema
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(
        git
        zsh-autosuggestions
        zsh-syntax-highlighting
        zsh-vi-mode
        )
source $ZSH/oh-my-zsh.sh

# 5. Inicialización de herramientas (Zoxide, P10k, Bun completions)
eval "$(zoxide init zsh)"
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# 6. Tus Funciones y Alias (Al final para que no estorben)
function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}

alias vim='nvim'
alias ls='lsd -lA'

alias lssh='lazyssh'
alias lg='lazygit'
alias ld='lazydocker'

# Alias para editar archivos de configuracion rápidamente
alias zshrc="nvim $ZSHCONF"
alias hyprc="nvim $HYPRCONF"

alias claude-local='ANTHROPIC_AUTH_TOKEN=ollama ANTHROPIC_API_KEY="" ANTHROPIC_BASE_URL=http://localhost:11434 claude --model gemma4:26b'

# Almacenamiento de las rutas a directorios y configuraciones más utilizados
export SDDMCONF="/usr/lib/sddm/sddm.conf.d/default.conf"
export KEDYCONF="/etc/keyd/default.conf"
export ZSHCONF="$HOME/dotfiles/endeavouros/zsh/.zshrc"
export HYPRCONF="$HOME/dotfiles/endeavouros/hypr/.config/hypr/hyprland.conf"

eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv zsh)"
