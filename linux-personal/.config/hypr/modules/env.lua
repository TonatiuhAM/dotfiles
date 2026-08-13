-- ==============================================
-- VARIABLES DE ENTORNO
-- ==============================================

hl.env("XCURSOR_THEME", "Adwaita")
hl.env("XCURSOR_SIZE", "24")

-- Programas por defecto
hl.env("EDITOR", "nvim")
hl.env("TERM", "kitty")
hl.env("var.terminal", "alacritty")
hl.env("BROWSER", "helium")

-- Directorios base XDG
hl.env("XDG_CONFIG_HOME", "/home/tona/.config")
hl.env("XDG_CACHE_HOME", "/home/tona/.cache")
hl.env("XDG_DATA_HOME", "/home/tona/.local/share")
hl.env("XDG_STATE_HOME", "/home/tona/.local/state")

-- Lenguajes y entornos de desarrollo
hl.env("CARGO_HOME", "/home/tona/.local/share/cargo")
hl.env("RUSTUP_HOME", "/home/tona/.local/share/rustup")
hl.env("BUN_INSTALL", "/home/tona/.local/share/bun")
hl.env("NPM_CONFIG_USERCONFIG", "/home/tona/.config/npm/npmrc")

-- var.terminal, shell y herramientas
hl.env("ZDOTDIR", "/home/tona/.config/zsh")
hl.env("ZSH", "/home/tona/.local/share/oh-my-zsh")
hl.env("HISTFILE", "/home/tona/.local/share/zsh/history")
hl.env("CLAUDE_CONFIG_DIR", "/home/tona/.config/claude")
hl.env("TMUX_CONF", "/home/tona/.config/tmux/tmux.conf")
hl.env("TMUX_TMPDIR", "/run/user/1000")
hl.env("GNUPGHOME", "/home/tona/.local/share/gnupg")
hl.env("WGETRC", "/home/tona/.config/wgetrc")

-- NVIDIA / CUDA
hl.env("__GL_SHADER_CACHE_PATH", "/home/tona/.cache/nvidia")

-- Otros
hl.env("KEYD_CONF", "/etc/keyd/default.conf")
hl.env("SDDM_CONF", "/usr/lib/sddm/sddm.conf.d/default.conf")
hl.env("APPS_DIR", "/home/tona/.local/share/applications/")
