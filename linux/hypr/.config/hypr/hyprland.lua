-- hyprland.lua

-- Construir config por partes
require("modules/autostart")
require("modules/keybinds")
require("modules/windows")
require("modules/animations")
require("modules/monitor")
require("modules/gestures")
require("colors")

-- Traer variables locales
local primary = primary
local outline_variant = outline_variant

-- CONFIGURACIÓN PRINCIPAL
hl.config({
	general = {
		gaps_in = 1,
		gaps_out = { top = 5, right = 5, bottom = 5, left = 5 },
		border_size = 2,
		col = {
			active_border = primary,
			inactive_border = "rgba(00000000)",
		},
		resize_on_border = false,
		allow_tearing = false,
		layout = "dwindle",
	},

	scrolling = {
		fullscreen_on_one_column = true,
		explicit_column_widths = "0.5, 1.0", -- 45% + 45% = 90% (deja un 10% de Peek en el borde)
		focus_fit_method = 1,
		follow_focus = true,
		direction = "right",
		wrap_focus = true,
	},

	dwindle = {
		force_split = 2,
		preserve_split = true,
	},

	master = {
		new_status = "master",
	},

	decoration = {
		rounding = 0,
		rounding_power = 2.0,
		active_opacity = 1.0,
		inactive_opacity = 1,
		shadow = {
			enabled = true,
			range = 5,
			render_power = 3,
			color = "rgba(00000066)",
		},
		blur = {
			enabled = true,
			size = 1,
			passes = 4,
		},
	},

	animations = {
		enabled = true,
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

	cursor = {
		no_hardware_cursors = true,
		enable_hyprcursor = false,
	},
})
