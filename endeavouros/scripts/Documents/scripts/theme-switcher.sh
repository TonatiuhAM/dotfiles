#!/usr/bin/env bash
# ╔═══════════════════════════════════════════════════════╗
# ║        Theme Changer — Hyprland + Matugen             ║
# ║              (con previews de imagen)                 ║
# ╚═══════════════════════════════════════════════════════╝

# ── Configuración ──────────────────────────────────────
WALL_DIR="$HOME/Wallpapers"
ROFI_THEME="$HOME/.config/rofi/launchers/theme-switcher-style-4.rasi"
CACHE_DIR="$HOME/.cache/theme-changer/thumbnails"

# Tamaño del thumbnail (px)
THUMB_SIZE=200

# ── Crear directorio de caché ──────────────────────────
mkdir -p "$CACHE_DIR"

# ── Verificar dependencias ─────────────────────────────
for dep in rofi matugen convert notify-send; do
  if ! command -v "$dep" &>/dev/null; then
    notify-send -u critical "Theme Changer" "❌ Falta dependencia: $dep"
    exit 1
  fi
done

# ── Verificar directorio de wallpapers ─────────────────
if [[ ! -d "$WALL_DIR" ]]; then
  notify-send -u critical "Theme Changer" "❌ No se encontró el directorio:\n$WALL_DIR"
  exit 1
fi

# ── Listar wallpapers ──────────────────────────────────
mapfile -t wallpapers < <(
  find "$WALL_DIR" -maxdepth 1 -type f \
    \( -iname "*.jpg" -o -iname "*.jpeg" \
    -o -iname "*.png" -o -iname "*.webp" \
    -o -iname "*.gif" \) \
    -printf "%f\n" | sort
)

if [[ ${#wallpapers[@]} -eq 0 ]]; then
  notify-send -u critical "Theme Changer" "❌ No se encontraron imágenes en:\n$WALL_DIR"
  exit 1
fi

# ── Generar thumbnails (solo si no existen ya en caché) ─
for wall in "${wallpapers[@]}"; do
  thumb="$CACHE_DIR/${wall%.*}.png"
  if [[ ! -f "$thumb" ]]; then
    convert "$WALL_DIR/$wall" \
      -thumbnail "${THUMB_SIZE}x${THUMB_SIZE}^" \
      -gravity center \
      -extent "${THUMB_SIZE}x${THUMB_SIZE}" \
      "$thumb" 2>/dev/null
  fi
done

# ── Construir lista para Rofi con iconos ───────────────
# Formato rofi con icono: "Nombre\0icon\x1f/ruta/al/icono"
rofi_input=""
for wall in "${wallpapers[@]}"; do
  thumb="$CACHE_DIR/${wall%.*}.png"
  if [[ -f "$thumb" ]]; then
    rofi_input+="${wall}\0icon\x1f${thumb}\n"
  else
    rofi_input+="${wall}\n"
  fi
done

# ── Abrir Rofi ─────────────────────────────────────────
selected=$(printf "%b" "$rofi_input" |
  rofi -dmenu \
    -p " Wallpaper" \
    -theme "$ROFI_THEME" \
    -no-custom \
    -i \
    -show-icons \
    -format s)

# Usuario canceló
[[ -z "$selected" ]] && exit 0

WALL_PATH="$WALL_DIR/$selected"

# ── Verificar archivo ──────────────────────────────────
if [[ ! -f "$WALL_PATH" ]]; then
  notify-send -u critical "Theme Changer" "❌ No se encontró:\n$selected"
  exit 1
fi

# ── Notificación: en progreso ──────────────────────────
THUMB_NOTIFY="$CACHE_DIR/${selected%.*}.png"
if [[ -f "$THUMB_NOTIFY" ]]; then
  notify-send -u normal -i "$THUMB_NOTIFY" \
    "Theme Changer" "🎨 Aplicando tema...\n<b>$selected</b>"
else
  notify-send -u normal \
    "Theme Changer" "🎨 Aplicando tema...\n<b>$selected</b>"
fi

# ── Aplicar con Matugen (no-interactivo) ──────────────
# --source-color-index 0 toma el primer color sin preguntar
matugen image "$WALL_PATH" --source-color-index 0 --type scheme-tonal-spot --mode dark

# ── Notificación: resultado ────────────────────────────
if [[ $? -eq 0 ]]; then
  notify-send -u low -i "$THUMB_NOTIFY" \
    "Theme Changer" "✅ Tema aplicado\n<b>$selected</b>"
else
  notify-send -u critical \
    "Theme Changer" "❌ Error al aplicar el tema\n$selected"
  exit 1
fi
