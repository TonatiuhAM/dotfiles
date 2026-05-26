#!/bin/sh
# variables env que se establecen al encender.


# ===== Programas por defecto =====
export EDITOR='nvim'
export TERM='kitty'
export TERMINAL='kitty'
export BROWSER='vivaldi'

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
export GNUPGHOME="$XDG_DATA_HOME/gnupg"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR" # O usa "$XDG_CACHE_HOME/tmux" si no tienes runtime
export WGETRC="$XDG_CONFIG_HOME/wgetrc"

# Nota para NVIDIA (.nv)
export __GL_SHADER_CACHE_PATH="$XDG_CACHE_HOME/nvidia"

# Otros
export KEYD_CONF="/etc/keyd/default.conf"
export SDDM_CONF="/usr/lib/sddm/sddm.conf.d/default.conf"
export APPS_DIR="/home/tona/.local/share/applications/"

if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
  exec Hyprland
fi
