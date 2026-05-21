-- hyprland.lua
-- Configuración corregida para Hyprland v0.55+ (sintaxis Lua oficial)

-- Colores (cargados dinámicamente desde colors.lua generado por matugen)
require("colors")
local primary = primary -- color principal de la paleta (borde activo)
local outline_variant = outline_variant -- tono apagado (borde inactivo)

-- Variables
local mainMod = "SUPER"
local terminal = "kitty"
local fileManager = "thunar"
local menu = "pkill rofi || bash ~/.config/rofi/launcher.sh"

-- ==============================================
-- MONITOR
-- ==============================================
hl.monitor({
	output = "HDMI-A-1",
	mode = "1920x1080@144",
	position = "auto",
	scale = 1,
})

-- ==============================================
-- AUTOSTART
-- ==============================================
hl.on("hyprland.start", function()
	-- hl.exec_cmd("waybar")
	hl.exec_cmd("swaync")
	hl.exec_cmd("qs")
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("/usr/lib/polkit-kde-agent-1")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")
	hl.exec_cmd("pypr")
	hl.exec_cmd("/usr/lib/polkit-gnome/polkit-gnome-authentication-agent-1")
	hl.exec_cmd("~/.local/bin/Handy_0.8.3_amd64.AppImage")
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
hl.config({
	general = {
		gaps_in = 5,
		gaps_out = { top = 8, right = 10, bottom = 8, left = 10 },
		border_size = 2,
		col = {
			active_border = primary,
			inactive_border = outline_variant,
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	decoration = {
		rounding = 10,
		rounding_power = 2.0,
		active_opacity = 1.0,
		inactive_opacity = 0.9,
		shadow = {
			enabled = true,
			range = 4,
			render_power = 3,
			color = "rgba(1a1a1aee)",
		},
		blur = {
			enabled = true,
			size = 1,
			passes = 4,
			vibrancy = 0.1696,
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
		disable_hyprland_logo = false,
	},

	input = {
		kb_layout = "latam",
		follow_mouse = 1,
		sensitivity = -0.8,
		touchpad = {
			natural_scroll = false,
		},
	},
})

-- ==============================================
-- ANIMACIONES
-- ==============================================
hl.curve("wind", { type = "bezier", points = { { 0.05, 0.9 }, { 0.1, 1.05 } } })
hl.curve("winIn", { type = "bezier", points = { { 0.1, 1.1 }, { 0.1, 1.1 } } })
hl.curve("winOut", { type = "bezier", points = { { 0.3, -0.3 }, { 0, 1 } } })
hl.curve("liner", { type = "bezier", points = { { 1, 1 }, { 1, 1 } } })
hl.curve("snap", { type = "bezier", points = { { 0.1, 1.0 }, { 0.1, 1.0 } } })

hl.animation({ leaf = "windows", enabled = true, speed = 3, bezier = "wind", style = "slide" })
hl.animation({ leaf = "windowsIn", enabled = true, speed = 3, bezier = "winIn", style = "slide" })
hl.animation({ leaf = "windowsOut", enabled = true, speed = 2, bezier = "winOut", style = "slide" })
hl.animation({ leaf = "windowsMove", enabled = true, speed = 3, bezier = "wind", style = "slide" })
hl.animation({ leaf = "border", enabled = true, speed = 1, bezier = "liner" })
hl.animation({ leaf = "borderangle", enabled = true, speed = 30, bezier = "liner", style = "loop" })
hl.animation({ leaf = "fade", enabled = true, speed = 4, bezier = "default" })
hl.animation({ leaf = "workspaces", enabled = true, speed = 3, bezier = "snap" })

-- ==============================================
-- GESTOS
-- ==============================================
hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})

-- ==============================================
-- WINDOW RULES & LAYER RULES
-- ==============================================
hl.window_rule({
	name = "suppress-maximize",
	match = { class = ".*" },
	suppress_event = "maximize",
})

hl.window_rule({
	name = "xwayland-drags",
	match = {
		class = "^$",
		title = "^$",
		xwayland = true,
		float = true,
		fullscreen = false,
		pin = false,
	},
	no_focus = true,
})

hl.window_rule({
	name = "pulsemixer-float",
	match = { initial_title = "pulsemixer" },
	float = true,
	center = true,
	size = { 800, 500 },
})

hl.window_rule({
	name = "impala-float",
	match = { initial_title = "impala" },
	float = true,
	center = true,
	size = { 1000, 1000 },
})

hl.window_rule({
	name = "bluetui-float",
	match = { initial_title = "bluetui" },
	float = true,
	center = true,
	size = { 800, 500 },
})

hl.window_rule({
	name = "style-picker",
	match = { class = "style-picker" },
	float = true,
	center = true,
	size = { 1200, 700 },
})

hl.window_rule({
	name = "quick-note",
	match = { class = "quick-note" },
	float = true,
	center = true,
	size = { 800, 600 },
})

hl.window_rule({
	name = "dev-workspace-picker",
	match = { class = "dev-workspace-picker" },
	float = true,
	center = true,
	size = { 700, 450 },
})

-- CORRECCIÓN: hl.layer_rule() sintaxis corregida
hl.layer_rule({
	name = "rofi-no-anim",
	match = { namespace = "^rofi$" },
	no_anim = true,
})

-- ==============================================
-- BINDS (ATAJOS)
-- ==============================================

-- Programas y utilidades
hl.bind("F9", hl.dsp.exec_cmd("kill -USR2 $(pgrep handy)"))
hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd(terminal .. " --title pulsemixer pulsemixer"))
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd(terminal .. " --title bluetui bluetui"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind(
	"SUPER + SHIFT + E",
	hl.dsp.exec_cmd("rofi -modi emoji -show emoji -emoji-mode copy -theme '~/.config/rofi/themes/launcher.rasi'")
)
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("~/Documents/scripts/quick-note.sh"))
hl.bind("SUPER + F", hl.dsp.exec_cmd(terminal .. " --override font_size=13 -e env EDITOR=nvim yazi"))
hl.bind("SUPER + Z", hl.dsp.window.fullscreen({ action = "toggle" }))
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind("SUPER + mouse:274", hl.dsp.exec_cmd("pypr zoom"), { mouse = true })
hl.bind("SUPER + comma", hl.dsp.exec_cmd("/home/tona/.config/rofi/modules/scripts.sh configs"))

--Recuperar mayor y menor que
hl.bind("CTRL + bar", hl.dsp.exec_cmd("wtype '>'"))
hl.bind("CTRL + SHIFT + bar", hl.dsp.exec_cmd("wtype '<'"))

-- Básicos
hl.bind("SUPER + Return", hl.dsp.exec_cmd(terminal))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd(terminal .. " sh -c 'tmux attach || tmux'"))
hl.bind("SUPER + b", hl.dsp.exec_cmd("vivaldi"))
hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd(fileManager))
hl.bind("SUPER + V", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind(
	"SUPER + D",
	hl.dsp.exec_cmd("bash ~/dotfiles/endeavouros/scripts/Documents/scripts/hypr-scripts/dev-layout.sh")
)
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("/home/tona/Documents/scripts/launch.sh"))

-- Navegación de foco (h/j/k/l estilo Vim)
hl.bind("SUPER + h", hl.dsp.focus({ direction = "l" }))
hl.bind("SUPER + l", hl.dsp.focus({ direction = "r" }))
hl.bind("SUPER + k", hl.dsp.focus({ direction = "u" }))
hl.bind("SUPER + j", hl.dsp.focus({ direction = "d" }))

-- Mover ventanas activas (SHIFT + h/j/k/l)
hl.bind("SUPER + SHIFT + h", hl.dsp.window.move({ direction = "l" }))
hl.bind("SUPER + SHIFT + l", hl.dsp.window.move({ direction = "r" }))
hl.bind("SUPER + SHIFT + k", hl.dsp.window.move({ direction = "u" }))
hl.bind("SUPER + SHIFT + j", hl.dsp.window.move({ direction = "d" }))

-- Workspaces 1-10 con bucle Lua
for i = 1, 10 do
	local key = i % 10
	hl.bind("SUPER + " .. key, hl.dsp.focus({ workspace = i }))
	hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

-- Drag y resize con mouse
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- SUBMAP: Redimensionar ventanas
hl.bind("SUPER + R", hl.dsp.submap("resize"))
hl.define_submap("resize", function()
	hl.bind("L", hl.dsp.window.resize({ x = 30, y = 0, relative = true }), { repeating = true })
	hl.bind("H", hl.dsp.window.resize({ x = -30, y = 0, relative = true }), { repeating = true })
	hl.bind("K", hl.dsp.window.resize({ x = 0, y = -30, relative = true }), { repeating = true })
	hl.bind("J", hl.dsp.window.resize({ x = 0, y = 30, relative = true }), { repeating = true })

	hl.bind("escape", hl.dsp.submap("reset"))
	hl.bind("return", hl.dsp.submap("reset"))
end)

-- Multimedia (locked = equivalente a bindel/bindl)
hl.bind(
	"XF86AudioRaiseVolume",
	hl.dsp.exec_cmd("wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioLowerVolume",
	hl.dsp.exec_cmd("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind(
	"XF86AudioMicMute",
	hl.dsp.exec_cmd("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"),
	{ locked = true, repeating = true }
)
hl.bind("XF86MonBrightnessUp", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%+"), { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd("brightnessctl -e4 -n2 set 5%-"), { locked = true, repeating = true })

-- Playerctl
hl.bind("XF86AudioNext", hl.dsp.exec_cmd("playerctl next"), { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev", hl.dsp.exec_cmd("playerctl previous"), { locked = true })
