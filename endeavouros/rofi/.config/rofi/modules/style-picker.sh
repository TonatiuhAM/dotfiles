#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════╗
# ║  style-picker.sh  —  Submódulo: Wallpapers                  ║
# ║                                                             ║
# ║  Lista de nombres a la izquierda.                           ║
# ║  Preview del wallpaper como ícono nativo de rofi            ║
# ║  a la derecha de cada ítem — se actualiza al navegar.       ║
# ║                                                             ║
# ║  Requiere: rofi-wayland, matugen, imagemagick               ║
# ╚══════════════════════════════════════════════════════════════╝

THEME="$HOME/.config/rofi/themes/launcher.rasi"
THEME_WIDE="$HOME/.config/rofi/themes/style-picker.rasi"
WALL_DIR="$HOME/Wallpapers"
CACHE_DIR="$HOME/.cache/style-picker/thumbs"

# Tamaño del thumbnail — ancho x alto en px
# Para wallpapers landscape 16:9, una buena proporción es 480x270
THUMB_W=320
THUMB_H=180

# ── Verificaciones ─────────────────────────────────────────────
for dep in rofi matugen convert notify-send; do
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

# ── Genera thumbnails landscape ────────────────────────────────
mkdir -p "$CACHE_DIR"
for wall in "${wallpapers[@]}"; do
    thumb="$CACHE_DIR/${wall%.*}.png"
    [[ -f "$thumb" ]] && continue
    convert "$WALL_DIR/$wall" \
        -resize "${THUMB_W}x${THUMB_H}^" \
        -gravity center \
        -extent "${THUMB_W}x${THUMB_H}" \
        "$thumb" 2>/dev/null
done

# ── Construye lista con íconos para rofi ──────────────────────
# Formato: "nombre\0icon\x1f/ruta/thumb.png"
# El nombre sin extensión queda más limpio visualmente
rofi_input=""
for wall in "${wallpapers[@]}"; do
    thumb="$CACHE_DIR/${wall%.*}.png"
    name="${wall%.*}"          # nombre sin extensión
    if [[ -f "$thumb" ]]; then
        rofi_input+="${name}\0icon\x1f${thumb}\n"
    else
        rofi_input+="${name}\n"
    fi
done

# ── Lanza rofi con tema wide ───────────────────────────────────
selected=$(printf "%b" "$rofi_input" \
    | rofi -dmenu \
           -p "󰏘" \
           -theme "$THEME_WIDE" \
           -no-custom \
           -show-icons \
           -i \
           -format s)

[[ -z "$selected" ]] && exit 0

# Reconstruye el nombre de archivo original (agrega extensión)
wall_path=""
for wall in "${wallpapers[@]}"; do
    [[ "${wall%.*}" == "$selected" ]] && wall_path="$WALL_DIR/$wall" && break
done

[[ -z "$wall_path" || ! -f "$wall_path" ]] && {
    notify-send -u critical "Style Picker" "❌ No encontrado: $selected"; exit 1; }

# ── Aplica con matugen ─────────────────────────────────────────
thumb_notify="$CACHE_DIR/${selected}.png"
[[ -f "$thumb_notify" ]] \
    && notify-send -u normal -i "$thumb_notify" \
           "Theme Changer" "🎨 Aplicando...\n<b>$selected</b>" \
    || notify-send -u normal \
           "Theme Changer" "🎨 Aplicando...\n<b>$selected</b>"

matugen image "$wall_path" \
    --source-color-index 0 \
    --type scheme-tonal-spot \
    --mode dark

[[ $? -eq 0 ]] \
    && notify-send -u low -i "$thumb_notify" \
           "Theme Changer" "✅ Tema aplicado\n<b>$selected</b>" \
    || notify-send -u critical \
           "Theme Changer" "❌ Error al aplicar\n$selected"
