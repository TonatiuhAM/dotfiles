export ZDOTDIR="$HOME/.config/zsh"

# Cargar variables de environment.d en sesiones SSH / no-systemd
if [ -d "$HOME/.config/environment.d" ]; then
    for f in "$HOME/.config/environment.d/"*.conf; do
        [ -f "$f" ] && source "$f"
    done
fi
