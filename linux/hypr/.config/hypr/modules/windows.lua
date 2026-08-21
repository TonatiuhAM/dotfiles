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
	name = "wiremix-float",
	match = { class = "wiremix" },
	float = true,
	center = true,
	size = { 800, 500 },
})

hl.window_rule({
	name = "nmtui-float",
	match = { class = "nmtui" },
	float = true,
	center = true,
	size = { 1000, 1000 },
})

hl.window_rule({
	name = "bluetui-float",
	match = { class = "bluetui" },
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
	name = "btop",
	match = { class = "btop" },
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

hl.window_rule({
	name = "emojis",
	match = { initial_title = "Smile" },
	float = true,
	size = { 500, 500 },
	center = true,
})

hl.window_rule({
	name = "fzf-global",
	match = { class = "fzf-global" },
	float = true,
	size = { 900, 500 },
	center = true,
})

hl.window_rule({
	name = "LocalSend",
	match = { class = "localsend" },
	float = true,
	size = { 500, 800 },
	move = {
		1300,
		150,
	},
})

-- Rustdesk
-- hl.window_rule({
-- 	name = "RustDesk",
-- 	match = { class = "rustdesk" },
-- 	float = true,
-- 	size = { 500, 800 },
-- 	move = {
-- 		1300,
-- 		150,
-- 	},
-- })
