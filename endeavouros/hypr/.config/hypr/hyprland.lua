-- hyprland.lua
-- Configuración corregida para Hyprland v0.55+ (sintaxis Lua oficial)

-- Colores (cargados dinámicamente desde colors.lua generado por matugen)
require("colors")
local primary         = primary          -- color principal de la paleta (borde activo)
local outline_variant = outline_variant  -- tono apagado (borde inactivo)

-- Variables
local mainMod    = "SUPER"
local terminal   = "kitty"
local fileManager = "thunar"
local menu       = "pkill rofi || bash ~/.config/rofi/launcher.sh"

-- ==============================================
-- MONITOR
-- ==============================================
-- CORRECCIÓN: usar hl.monitor({}) en lugar de hl.config({ monitor = ... })
hl.monitor({
    output   = "HDMI-A-1",
    mode     = "1920x1080@144",
    position = "auto",
    scale    = 1,
})

-- ==============================================
-- AUTOSTART
-- ==============================================
-- CORRECCIÓN: el evento correcto es "hyprland.start" (esto estaba bien)
hl.on("hyprland.start", function()
    hl.exec_cmd("waybar")
    hl.exec_cmd("awww-daemon")
    hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
    hl.exec_cmd("/usr/lib/polkit-kde-agent-1")
    hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
    hl.exec_cmd("swaync")
    hl.exec_cmd("pypr")
    hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
end)

-- ==============================================
-- VARIABLES DE ENTORNO
-- ==============================================
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")

-- ==============================================
-- CONFIGURACIÓN PRINCIPAL
-- ==============================================
-- CORRECCIÓN: col.active_border y col.inactive_border ahora van dentro de col = { ... }
-- CORRECCIÓN: gaps_out recibe un string "top right bottom left", no una tabla con keys
hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = { top = 8, right = 10, bottom = 8, left = 10 },
        border_size = 2,
        col = {
            active_border   = primary,
            inactive_border = outline_variant,
        },
        resize_on_border = false,
        allow_tearing    = false,
        layout           = "dwindle",
    },

    decoration = {
        rounding       = 10,
        rounding_power = 2.0,
        active_opacity   = 1.0,
        inactive_opacity = 0.9,
        shadow = {
            enabled      = true,
            range        = 4,
            render_power = 3,
            -- CORRECCIÓN: el color puede ser string rgba o hex numérico
            color        = "rgba(1a1a1aee)",
        },
        blur = {
            enabled   = true,
            size      = 1,
            passes    = 4,
            vibrancy  = 0.1696,
        },
    },

    animations = {
        enabled = true,
    },

    dwindle = {
        preserve_split = true,
    },

    master = {
        new_status = "master",
    },

    misc = {
        force_default_wallpaper = -1,
        disable_hyprland_logo   = false,
    },

    input = {
        kb_layout   = "latam",
        follow_mouse = 1,
        sensitivity  = -0.8,
        touchpad = {
            natural_scroll = false,
        },
    },
})

-- ==============================================
-- ANIMACIONES
-- ==============================================
-- CORRECCIÓN: bezier y animation ya NO van dentro de hl.config({ animations = {...} })
-- Ahora se definen con hl.curve() y hl.animation() por separado
hl.curve("wind",   { type = "bezier", points = { {0.05, 0.9},  {0.1,  1.05} } })
hl.curve("winIn",  { type = "bezier", points = { {0.1,  1.1},  {0.1,  1.1}  } })
hl.curve("winOut", { type = "bezier", points = { {0.3,  -0.3}, {0,    1}    } })
hl.curve("liner",  { type = "bezier", points = { {1,    1},    {1,    1}    } })
hl.curve("snap",   { type = "bezier", points = { {0.1,  1.0},  {0.1,  1.0}  } })

hl.animation({ leaf = "windows",     enabled = true, speed = 3, bezier = "wind",   style = "slide" })
hl.animation({ leaf = "windowsIn",   enabled = true, speed = 3, bezier = "winIn",  style = "slide" })
hl.animation({ leaf = "windowsOut",  enabled = true, speed = 2, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "wind",   style = "slide" })
hl.animation({ leaf = "border",      enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade",        enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces",  enabled = true, speed = 3, bezier = "snap" })

-- ==============================================
-- GESTOS
-- ==============================================
-- CORRECCIÓN: hl.gesture() recibe una tabla, no argumentos posicionales
hl.gesture({
    fingers   = 3,
    direction = "horizontal",
    action    = "workspace",
})

-- ==============================================
-- WINDOW RULES & LAYER RULES
-- ==============================================
hl.window_rule({
    name  = "suppress-maximize",
    match = { class = ".*" },
    suppress_event = "maximize",
})

hl.window_rule({
    name  = "xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },
    no_focus = true,
})

hl.window_rule({
    name   = "pulsemixer-float",
    match  = { initial_title = "pulsemixer" },
    float  = true,
    center = true,
    size   = { 800, 500 },
})

hl.window_rule({
    name   = "impala-float",
    match  = { initial_title = "impala" },
    float  = true,
    center = true,
    size   = { 1000, 1000 },
})

hl.window_rule({
    name   = "bluetui-float",
    match  = { initial_title = "bluetui" },
    float  = true,
    center = true,
    size   = { 800, 500 },
})

hl.window_rule({
    name   = "style-picker",
    match  = { class = "style-picker" },
    float  = true,
    center = true,
    size   = { 1200, 700 },
})

hl.window_rule({
    name   = "quick-note",
    match  = { class = "quick-note" },
    float  = true,
    center = true,
    size   = { 800, 600 },
})

-- CORRECCIÓN: hl.layer_rule() sintaxis corregida
hl.layer_rule({
    name    = "rofi-no-anim",
    match   = { namespace = "^rofi$" },
    no_anim = true,
})

-- ==============================================
-- BINDS (ATAJOS)
-- ==============================================
-- CORRECCIÓN: hl.dsp.exec_cmd() se llama directamente, sin hl.dsp. como prefijo extra
-- CORRECCIÓN: para teclas multimedia sin modificador, el formato es solo la tecla (sin "")
-- CORRECCIÓN: bindel/bindl equivalen a { locked=true, repeating=true } como opciones

-- Programas y utilidades
hl.bind(mainMod .. " + ALT + D", hl.dsp.exec_cmd("/usr/lib/hyprwhspr/config/hyprland/hyprwhspr-tray.sh record"))
hl.bind(mainMod .. " + ALT + S", hl.dsp.exec_cmd(terminal .. " --title pulsemixer pulsemixer"))
hl.bind(mainMod .. " + ALT + B", hl.dsp.exec_cmd(terminal .. " --title bluetui bluetui"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd("rofi -modi emoji -show emoji -emoji-mode copy -theme '~/.config/rofi/themes/launcher.rasi'"))
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.exec_cmd("~/Documents/scripts/quick-note.sh"))
hl.bind(mainMod .. " + F",         hl.dsp.exec_cmd(terminal .. " --override font_size=13 -e env EDITOR=nvim yazi"))
hl.bind(mainMod .. " + Z",         hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd("swaync-client -t"))
hl.bind(mainMod .. " + mouse:274", hl.dsp.exec_cmd("pypr zoom"), { mouse = true })
hl.bind(mainMod .. " + comma",     hl.dsp.exec_cmd("/home/tona/.config/rofi/modules/scripts.sh configs"))

-- Básicos
hl.bind(mainMod .. " + Return",  hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + b",       hl.dsp.exec_cmd("vivaldi"))
hl.bind(mainMod .. " + q",       hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + F", hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + V",       hl.dsp.layout("togglesplit"))
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + SPACE",   hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + P",       hl.dsp.window.pseudo())
hl.bind(mainMod .. " + SHIFT + R", hl.dsp.exec_cmd("/home/tona/.config/waybar/Scripts/launcher/launch.sh"))

-- Navegación de foco (h/j/k/l estilo Vim)
hl.bind(mainMod .. " + h", hl.dsp.focus({ direction = "l" }))
hl.bind(mainMod .. " + l", hl.dsp.focus({ direction = "r" }))
hl.bind(mainMod .. " + k", hl.dsp.focus({ direction = "u" }))
hl.bind(mainMod .. " + j", hl.dsp.focus({ direction = "d" }))

-- Mover ventanas activas (SHIFT + h/j/k/l)
hl.bind(mainMod .. " + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind(mainMod .. " + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind(mainMod .. " + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind(mainMod .. " + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Workspaces 1-10 con bucle Lua
for i = 1, 10 do
    local key = i % 10
    hl.bind(mainMod .. " + " .. key,           hl.dsp.focus({ workspace = i }))
    hl.bind(mainMod .. " + SHIFT + " .. key,   hl.dsp.window.move({ workspace = i }))
end

-- Drag y resize con mouse
hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- SUBMAP: Redimensionar ventanas
hl.bind(mainMod .. " + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
    hl.bind("L",      hl.dsp.window.resize({ x =  30, y =   0 }), { repeating = true })
    hl.bind("H",      hl.dsp.window.resize({ x = -30, y =   0 }), { repeating = true })
    hl.bind("K",      hl.dsp.window.resize({ x =   0, y = -30 }), { repeating = true })
    hl.bind("J",      hl.dsp.window.resize({ x =   0, y =  30 }), { repeating = true })
    hl.bind("right",  hl.dsp.window.resize({ x =  30, y =   0 }), { repeating = true })
    hl.bind("left",   hl.dsp.window.resize({ x = -30, y =   0 }), { repeating = true })
    hl.bind("up",     hl.dsp.window.resize({ x =   0, y = -30 }), { repeating = true })
    hl.bind("down",   hl.dsp.window.resize({ x =   0, y =  30 }), { repeating = true })
    hl.bind("escape", hl.dsp.submap("reset"))
    hl.bind("return", hl.dsp.submap("reset"))
end)

-- Multimedia (locked = equivalente a bindel/bindl)
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),  { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),        { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),        { locked = true, repeating = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),      { locked = true, repeating = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"),                    { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"),                    { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),        { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"),  { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),    { locked = true })
