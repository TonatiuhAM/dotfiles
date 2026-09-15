#!/usr/bin/env bash
# tmux-sessionizer.sh — selector inteligente de sesiones de tmux
#
# Inspirado en https://github.com/joshmedeski/t-smart-tmux-session-manager
# Combina sesiones de tmux (por uso reciente) + directorios de zoxide en un
# único picker de fzf. Sirve para cualquier carpeta, no solo proyectos de
# ~/dev. Crea la sesión si no existe y hace attach/switch-client según
# corresponda.
#
# Uso:
#   tmux-sessionizer.sh                 Modo interactivo (fzf)
#   tmux-sessionizer.sh <ruta|nombre>   Va directo a esa sesión/ruta
#   tmux-sessionizer.sh --create-only [ruta|nombre]
#                                        Igual, pero solo crea/localiza la
#                                        sesión e imprime su nombre en stdout,
#                                        sin hacer attach/switch-client
#                                        (usado por dev-layout.sh)

set -euo pipefail

CREATE_ONLY=0
if [ "${1:-}" = "--create-only" ]; then
    CREATE_ONLY=1
    shift
fi

# Determinar si el servidor de tmux está corriendo
if tmux list-sessions &>/dev/null; then
    TMUX_RUNNING=0
else
    TMUX_RUNNING=1
fi

# Posición del usuario respecto a tmux:
# serverless - no hay servidor de tmux corriendo
# attached   - estamos dentro de una sesión de tmux
# detached   - hay servidor corriendo pero no estamos adentro
T_RUNTYPE="serverless"
if [ "$TMUX_RUNNING" -eq 0 ]; then
    if [ -n "${TMUX:-}" ]; then
        T_RUNTYPE="attached"
    else
        T_RUNTYPE="detached"
    fi
fi

HOME_REPLACER="s|^$HOME/|~/|"

get_sessions_by_mru() {
    local current_sid=""
    if [ "$T_RUNTYPE" = "attached" ]; then
        current_sid=$(tmux display-message -p "#{session_id}")
    fi
    tmux list-sessions \
        -f "#{!=:#{session_id},$current_sid}" \
        -F '#{session_last_attached} #{session_name}' 2>/dev/null \
        | sort --numeric-sort --reverse | awk '{print $2}; END {print "———"}'
}

get_zoxide_results() {
    zoxide query -l | sed -e "$HOME_REPLACER"
}

get_fzf_results() {
    if [ "$TMUX_RUNNING" -eq 0 ]; then
        get_sessions_by_mru && get_zoxide_results
    else
        get_zoxide_results
    fi
}

PROMPT='>  '
HEADER=" ^s sesiones ^x zoxide ^f find"
BORDER_LABEL=' tmux-sessionizer '
FIND_BIND='ctrl-f:change-prompt(find> )+reload(find ~ -maxdepth 3 -type d)'
SESSION_BIND="ctrl-s:change-prompt(sesiones> )+reload(tmux list-sessions -F '#S' 2>/dev/null)"
ZOXIDE_BIND="ctrl-x:change-prompt(zoxide> )+reload(zoxide query -l | sed -e \"$HOME_REPLACER\")"
TAB_BIND="tab:down,btab:up"

if [ $# -ge 1 ]; then
    ARG=$1
    if zoxide query "$ARG" &>/dev/null; then
        RESULT=$(zoxide query "$ARG")
    elif [ -d "$ARG" ]; then
        RESULT=$ARG
    else
        echo "No se encontró ese directorio." >&2
        exit 1
    fi
else
    case $T_RUNTYPE in
    attached)
        RESULT=$(
            (get_fzf_results) | fzf-tmux \
                --bind "$FIND_BIND" \
                --bind "$SESSION_BIND" \
                --bind "$TAB_BIND" \
                --bind "$ZOXIDE_BIND" \
                --border-label "$BORDER_LABEL" \
                --header "$HEADER" \
                --no-sort \
                --prompt "$PROMPT" \
                -p 53%,58%
        )
        ;;
    detached)
        RESULT=$(
            (get_fzf_results) | fzf \
                --bind "$FIND_BIND" \
                --bind "$SESSION_BIND" \
                --bind "$TAB_BIND" \
                --bind "$ZOXIDE_BIND" \
                --border \
                --border-label "$BORDER_LABEL" \
                --header "$HEADER" \
                --no-sort \
                --prompt "$PROMPT"
        )
        ;;
    serverless)
        RESULT=$(
            (get_fzf_results) | fzf \
                --bind "$FIND_BIND" \
                --bind "$TAB_BIND" \
                --bind "$ZOXIDE_BIND" \
                --border \
                --border-label "$BORDER_LABEL" \
                --header " ^x zoxide ^f find" \
                --no-sort \
                --prompt "$PROMPT"
        )
        ;;
    esac
fi

[ -z "${RESULT:-}" ] && exit 0

RESULT=$(echo "$RESULT" | sed -e "s|^~/|$HOME/|") # recuperar ruta real

zoxide add "$RESULT" &>/dev/null || true

if [[ $RESULT != /* ]]; then
    # No es una ruta (viene de la lista de sesiones de tmux): es el nombre
    SESSION_NAME=$RESULT
else
    SESSION_NAME=$(basename "$RESULT" | tr ' .:' '_')
fi

SESSION=""
if [ "$T_RUNTYPE" != "serverless" ]; then
    SESSION=$(tmux list-sessions -F '#S' 2>/dev/null | grep -x "$SESSION_NAME" || true)
fi

if [ -z "$SESSION" ]; then
    SESSION="$SESSION_NAME"
    if [ -e "$RESULT/.t" ]; then
        tmux new-session -d -s "$SESSION" -c "$RESULT" "$RESULT/.t"
    else
        tmux new-session -d -s "$SESSION" -c "$RESULT"
    fi
fi

if [ "$CREATE_ONLY" -eq 1 ]; then
    echo "$SESSION"
    exit 0
fi

case $T_RUNTYPE in
attached)
    tmux switch-client -t "$SESSION"
    ;;
detached | serverless)
    tmux attach -t "$SESSION"
    ;;
esac
