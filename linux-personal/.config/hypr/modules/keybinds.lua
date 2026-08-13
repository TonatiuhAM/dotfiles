-- ==============================================
-- KEYBINDS
-- ==============================================

local var = require("modules/vars")

-- Programas y utilidades
hl.bind("SUPER + Tab", hl.dsp.window.cycle_next({}))
hl.bind("F9", hl.dsp.exec_cmd("kill -USR2 $(pgrep handy)"))
hl.bind("SUPER + ALT + S", hl.dsp.exec_cmd(var.terminal .. " --class wiremix -e wiremix"))
hl.bind("SUPER + ALT + B", hl.dsp.exec_cmd(var.terminal .. " --class bluetui -e bluetui"))
hl.bind("SUPER + SHIFT + S", hl.dsp.exec_cmd('grim -g "$(slurp)" - | wl-copy'))
hl.bind("SUPER + period", hl.dsp.exec_cmd("flatpak run it.mijorus.smile"))
hl.bind("SUPER + SHIFT + N", hl.dsp.exec_cmd("$XDG_CONFIG_HOME/Scripts/quick-note.sh"))
hl.bind("SUPER + F", hl.dsp.exec_cmd(var.terminal .. " -o 'font.size'=13 -e yazi")) -- FALTA EDITOR NVIM?
hl.bind("SUPER + N", hl.dsp.exec_cmd("swaync-client -t"))
hl.bind("SUPER + comma", hl.dsp.exec_cmd("$XDG_CONFIG_HOME/Scripts/config-picker.sh"))
hl.bind("SUPER + ALT + N", hl.dsp.exec_cmd(var.terminal .. " -e nvim ~/documents/Obsidian/the-vault/bullet-journal.md"))

-- Zoom dinámico de acuerdo al layout actual
hl.bind("SUPER + Z", function()
	local current_layout = hl.get_config("general.layout")
	if current_layout == "scrolling" then
		hl.dispatch(hl.dsp.layout("colresize +conf"))
	elseif current_layout == "dwindle" then
		hl.dispatch(hl.dsp.window.fullscreen({ mode = "maximized", action = "toggle" }))
	end
end, { description = "Alterna ancho entre actual y máximo" })

--Recuperar mayor y menor que
hl.bind("CTRL + bar", hl.dsp.exec_cmd("wtype '>'"))
hl.bind("CTRL + SHIFT + bar", hl.dsp.exec_cmd("wtype '<'"))

-- Básicos
hl.bind("SUPER + Return", hl.dsp.exec_cmd(var.terminal))
hl.bind("SUPER + SHIFT + Return", hl.dsp.exec_cmd(var.terminal .. " -e sh -c 'tmux attach || tmux'"))
hl.bind("SUPER + b", hl.dsp.exec_cmd("helium"))
hl.bind("SUPER + q", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + F", hl.dsp.exec_cmd(var.fileManager))
hl.bind("SUPER + V", hl.dsp.layout("togglesplit"))
hl.bind("SUPER + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind("SUPER + SPACE", hl.dsp.exec_cmd(var.menu))
hl.bind("SUPER + P", hl.dsp.window.pseudo())
hl.bind("SUPER + D", hl.dsp.exec_cmd("$XDG_CONFIG_HOME/Scripts/dev-layout.sh"))
hl.bind("SUPER + SHIFT + R", hl.dsp.exec_cmd("$XDG_CONFIG_HOME/Scripts/launch.sh"))

-- Workspaces especiales
hl.bind("SUPER + SHIFT + M", hl.dsp.window.move({ workspace = "special:M" }))
hl.bind("SUPER + M", hl.dsp.workspace.toggle_special("M"))

-- Navegación entre workspaces con flechas
hl.bind("SUPER+Left", hl.dsp.focus({ workspace = "-1" }))
hl.bind("SUPER+Right", hl.dsp.focus({ workspace = "+1" }))

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

-- HELIUM BROWSER: Navegación entre pestañas con Ctrl+h,l
hl.bind(
	"CTRL+h",
	hl.dsp.exec_cmd(
		"bash -c 'if hyprctl activewindow | grep -q \"class: helium\"; then wtype -M ctrl -M shift -k Tab -m shift -m ctrl; else wtype -M ctrl -k h -m ctrl; fi'"
	)
)

hl.bind(
	"CTRL+l",
	hl.dsp.exec_cmd(
		"bash -c 'if hyprctl activewindow | grep -q \"class: helium\"; then wtype -M ctrl -k Tab -m ctrl; else wtype -M ctrl -k l -m ctrl; fi'"
	)
)

hl.bind(
	"CTRL+space",
	hl.dsp.exec_cmd(
		"bash -c 'if hyprctl activewindow | grep -q \"class: helium\"; then wtype -M ctrl -k l -m ctrl; else wtype -k space; fi'"
	)
)

-- Glass magnifier zoom
local MAX_ZOOM = 3
local MIN_ZOOM = 1
local ZOOM_TOGGLE_FACTOR = 1.5

---@param offset number
---@return nil
local function zoom(offset)
	local current = hl.get_config("cursor.zoom_factor")
	if offset ~= nil then
		current = current + offset
	elseif current ~= MIN_ZOOM then
		current = MIN_ZOOM
	else
		current = ZOOM_TOGGLE_FACTOR
	end
	current = math.max(MIN_ZOOM, math.min(MAX_ZOOM, current))
	hl.config({ cursor = { zoom_factor = current } })
end

hl.bind("SUPER + ALT+ Z", zoom)
hl.bind("SUPER + KP_ADD", function()
	zoom(0.5)
end)
hl.bind("SUPER + KP_Subtract", function()
	zoom(-0.5)
end)
