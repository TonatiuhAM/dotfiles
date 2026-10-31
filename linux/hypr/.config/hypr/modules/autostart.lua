-- ==============================================
-- AUTOSTART
-- ==============================================

local var = require("modules/vars")

hl.on("hyprland.start", function()
	-- Iniciadores de hyrpland necesario
	-- [UWSM TEST 2026-08-06] Comentado: UWSM ya hace esto automáticamente
	-- hl.exec_cmd("systemctl --user start hyprland-session.target") -- Iniciar los servicios del sistema
	-- hl.exec_cmd("dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	-- hl.exec_cmd("systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP")
	hl.exec_cmd("gnome-keyring-daemon --start --components=secrets")

	-- Iniciadores de aplicaciones
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd(var.chillpillRun) -- barra + launcher + notificaciones
	hl.exec_cmd("wl-paste --type text --watch cliphist store")
	hl.exec_cmd("wl-paste --type image --watch cliphist store")
	hl.exec_cmd("hypridle")
	hl.exec_cmd("tailscale systray")
	-- hl.exec_cmd("~/.local/bin/Handy_0.8.3_amd64.AppImage")
end)
