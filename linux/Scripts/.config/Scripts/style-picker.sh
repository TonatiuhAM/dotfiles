#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  style-picker.sh  —  Submódulo: Selector de Wallpapers      ║
# ║                                                             ║
# ║  fzf + chafa dentro de kitty flotante                       ║
# ║  Requiere: fzf, chafa, kitty, matugen, notify-send          ║
# ║  (usa Kitty a propósito: Alacritty no soporta gráficos      ║
# ║  en terminal, necesarios para el preview de chafa)          ║
# ╚══════════════════════════════════════════════════════════════╝

WALL_DIR="$HOME/Wallpapers"
SCRIPT="$(realpath "${BASH_SOURCE[0]}")"

# ── Relanza dentro de kitty si no viene con --interactive ──────
if [[ "$1" != "--interactive" ]]; then
    exec kitty \
        --class="style-picker" \
        --title="style-picker" \
        -e bash "$SCRIPT" --interactive
fi

# ── PATH ────────────────────────────────────────────────────────
# bash no-login/no-interactive no carga ~/.config/zsh/.zprofile,
# donde vive CARGO_HOME (matugen se instaló vía cargo).
export PATH="$HOME/.local/share/cargo/bin:$PATH"

# ── Dependencias ───────────────────────────────────────────────
for dep in fzf chafa matugen notify-send; do
    command -v "$dep" &>/dev/null || {
        notify-send -u critical "Style Picker" "❌ Falta: $dep"; exit 1; }
done

[[ -d "$WALL_DIR" ]] || {
    notify-send -u critical "Style Picker" "❌ No existe: $WALL_DIR"; exit 1; }

# ── Selector fzf navegable (entra a subcarpetas con Enter) ─────
# Estructura esperada: $WALL_DIR/<Tema>/wallpaper.png (Catppuccin,
# Nord, Everforest, Matugen...), pero también funciona con imágenes
# sueltas directo en $WALL_DIR.
current_dir="$WALL_DIR"

while true; do
    mapfile -t entries < <(
        {
            [[ "$current_dir" != "$WALL_DIR" ]] && printf '..\n'
            find "$current_dir" -maxdepth 1 -mindepth 1 -type d -printf '%f/\n' 2>/dev/null | sort
            find "$current_dir" -maxdepth 1 -type f \
                \( -iname "*.jpg" -o -iname "*.jpeg" \
                -o -iname "*.png" -o -iname "*.webp" \) \
                -printf '%f\n' 2>/dev/null | sort
        }
    )

    [[ ${#entries[@]} -eq 0 ]] && {
        notify-send -u critical "Style Picker" "❌ Vacío: $current_dir"; exit 1; }

    rel="${current_dir#$WALL_DIR}"
    rel="${rel#/}"

    export CUR_DIR="$current_dir"
    selected=$(printf '%s\n' "${entries[@]}" \
        | fzf \
            --prompt="󰏘  ${rel:-Wallpapers} > " \
            --preview '
                entry={}
                entry_path="$CUR_DIR/$entry"
                if [[ "$entry" == ".." ]]; then
                    echo "⬅  Subir un nivel"
                elif [[ -d "$entry_path" ]]; then
                    echo "📁 $entry"; echo
                    ls -1 "$entry_path" 2>/dev/null
                else
                    chafa --size=${FZF_PREVIEW_COLUMNS}x${FZF_PREVIEW_LINES} "$entry_path"
                fi
            ' \
            --preview-window=right:65%:wrap \
            --height=100% \
            --border=none \
            --no-info \
            --cycle)

    [[ -z "$selected" ]] && exit 0

    if [[ "$selected" == ".." ]]; then
        current_dir="$(dirname "$current_dir")"
        continue
    fi

    if [[ "$selected" == */ ]]; then
        current_dir="$current_dir/${selected%/}"
        continue
    fi

    wall_path="$current_dir/$selected"
    break
done

[[ ! -f "$wall_path" ]] && {
    notify-send -u critical "Style Picker" "❌ No encontrado: $selected"
    exit 1
}

# ── Aplica wallpaper (+ matugen, deshabilitado temporalmente) ──
notify-send -u normal "Theme Changer" "🎨 Aplicando...\n<b>${selected%.*}</b>"

awww img "$wall_path" --transition-type center 2>/dev/null

# TODO(cerebro): matugen queda como 4º modo de tema (dinámico), pero
# mientras no exista el selector que detecte la carpeta del wallpaper,
# correrlo aquí siempre pisaría Catppuccin/Nord/Everforest en varios
# programas (kitty, alacritty, hyprland, quickshell, GTK, btop, rofi).
# Deshabilitado hasta conectar esa lógica.
# matugen image "$wall_path" \
#     --source-color-index 0 \
#     --type scheme-tonal-spot \
#     --mode dark
#
# if [[ $? -eq 0 ]]; then
#     notify-send -u low "Theme Changer" "✅ Tema aplicado\n<b>${selected%.*}</b>"
# else
#     notify-send -u critical "Theme Changer" "❌ Error al aplicar\n${selected%.*}"
# fi

notify-send -u low "Theme Changer" "🖼️ Wallpaper aplicado\n<b>${selected%.*}</b>"
