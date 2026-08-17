#!/bin/sh

# Asegurar directorios críticos
[ -n "$XDG_DATA_HOME" ] && mkdir -p "$XDG_DATA_HOME/zsh"

# Homebrew
if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Construir PATH
export PATH="$CARGO_HOME/bin:$BUN_INSTALL/bin:$HOME/.opencode/bin:$HOME/bin:$HOME/.local/bin:/opt/cuda/bin:$PATH"

# Auto-arranque de entorno gráfico (Fallback para TTY1)
if [[ -z $DISPLAY ]] && [[ $(tty) = /dev/tty1 ]]; then
    exec start-hyprland -- -c "${XDG_CONFIG_HOME:-$HOME/.config}/hypr/hyprland.lua"
fi
