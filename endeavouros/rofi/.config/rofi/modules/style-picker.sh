#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  style-picker.sh  —  Submódulo: Selector de Wallpapers      ║
# ║                                                             ║
# ║  fzf + chafa dentro de kitty flotante                       ║
# ║  Requiere: fzf, chafa, kitty, matugen, notify-send          ║
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

# ── Dependencias ───────────────────────────────────────────────
for dep in fzf chafa matugen notify-send; do
    command -v "$dep" &>/dev/null || {
        notify-send -u critical "Style Picker" "❌ Falta: $dep"; exit 1; }
done

[[ -d "$WALL_DIR" ]] || {
    notify-send -u critical "Style Picker" "❌ No existe: $WALL_DIR"; exit 1; }

# ── Lista wallpapers ───────────────────────────────────────────
mapfile -t wallpapers < <(
    find "$WALL_DIR" -maxdepth 1 -type f \
        \( -iname "*.jpg" -o -iname "*.jpeg" \
        -o -iname "*.png" -o -iname "*.webp" \) \
        -printf "%f\n" | sort
)

[[ ${#wallpapers[@]} -eq 0 ]] && {
    notify-send -u critical "Style Picker" "❌ Sin imágenes en: $WALL_DIR"; exit 1; }

# ── Selector fzf + preview chafa ──────────────────────────────
selected=$(printf '%s\n' "${wallpapers[@]}" \
    | fzf \
        --prompt="󰏘  Wallpaper: " \
        --preview "chafa --size=\${FZF_PREVIEW_COLUMNS}x\${FZF_PREVIEW_LINES} $WALL_DIR/{}" \
        --preview-window=right:65%:wrap \
        --height=100% \
        --border=none \
        --no-info \
        --cycle)

[[ -z "$selected" ]] && exit 0

wall_path="$WALL_DIR/$selected"
[[ ! -f "$wall_path" ]] && {
    notify-send -u critical "Style Picker" "❌ No encontrado: $selected"
    exit 1
}

# ── Aplica wallpaper + matugen ────────────────────────────────
notify-send -u normal "Theme Changer" "🎨 Aplicando...\n<b>${selected%.*}</b>"

awww img "$wall_path" --transition-type center

matugen image "$wall_path" \
    --source-color-index 0 \
    --type scheme-tonal-spot \
    --mode dark

if [[ $? -eq 0 ]]; then
    notify-send -u low "Theme Changer" "✅ Tema aplicado\n<b>${selected%.*}</b>"
else
    notify-send -u critical "Theme Changer" "❌ Error al aplicar\n${selected%.*}"
fi
