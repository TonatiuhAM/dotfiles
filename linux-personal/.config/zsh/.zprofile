#!/bin/sh
# variables env que se establecen al encender.

# ===== Programas por defecto =====
export EDITOR='nvim'
export TERM='kitty'
export TERMINAL='kitty'
export BROWSER='helium-browser'

# ===== Directorios base XDG =====
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"


# -------------------------------------------------------------------
# Redirección de aplicaciones al estándar XDG
# -------------------------------------------------------------------

# Lenguajes y Entornos de Desarrollo
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"
export BUN_INSTALL="$XDG_DATA_HOME/bun"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# Terminal, Shell y Herramientas de Sistema
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
export ZSH="$XDG_DATA_HOME/oh-my-zsh" # Reubicamos Oh My Zsh a XDG Data
export HISTFILE="$XDG_DATA_HOME/zsh/history"
export CLAUDE_CONFIG_DIR="$XDG_CONFIG_HOME/claude"
export TMUX_CONF="$XDG_CONFIG_HOME/tmux/tmux.conf"
export HISTSIZE=10000
export SAVEHIST=10000

export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

# Configuración de librerías para NVIDIA y CUDA
export __GL_SHADER_CACHE_PATH="$XDG_CACHE_HOME/nvidia"
export LD_LIBRARY_PATH="$LD_LIBRARY_PATH:/opt/cuda/lib64"

# Otros y Rutas de Scripts
export KEYD_CONF="/etc/keyd/default.conf"
export SDDM_CONF="/usr/lib/sddm/sddm.conf.d/default.conf"
export APPS_DIR="$XDG_DATA_HOME/applications/"

# Asegurar que la carpeta de historial de Zsh exista
mkdir -p "$XDG_DATA_HOME/zsh"

# -------------------------------------------------------------------
# Configuración de Entorno y $PATH (Homebrew y Binarios)
# -------------------------------------------------------------------
# Inicializar Homebrew en el login shell para optimizar rendimiento
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Construir el PATH limpio unificando todo lo que tenías en el .zshrc
export PATH="$CARGO_HOME/bin:$BUN_INSTALL/bin:$HOME/.opencode/bin:$HOME/bin:$HOME/.local/bin:/opt/cuda/bin:$PATH"

# -------------------------------------------------------------------
# Auto-arranque de entorno gráfico
# -------------------------------------------------------------------
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec start-hyprland -- -c "$XDG_CONFIG_HOME/hypr/hyprland.lua"
fi
