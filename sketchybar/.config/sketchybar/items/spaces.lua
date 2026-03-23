local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

local spaces = {}

for i = 1, 10, 1 do
	local space = sbar.add("space", "space." .. i, {
		space = i,
		icon = {
			string = i,
			padding_left = 10,
			padding_right = 10,
			highlight_color = colors.green,
		},
		label = {
			padding_right = 10,
			color = colors.grey,
			highlight_color = colors.white,
			font = "sketchybar-app-font:Regular:16.0",
			drawing = false,
		},
		padding_right = 1,
		padding_left = 1,
		background = {
			color = colors.bg1,
		},
		click_script = "yabai -m space --focus " .. i,
	})

	spaces[i] = space

	sbar.add("bracket", { space.name }, {
		background = { color = colors.transparent },
	})

	sbar.add("space", "space.padding." .. i, {
		space = i,
		script = "",
		width = settings.group_paddings,
	})

	space:subscribe("space_change", function(env)
		local selected = env.SELECTED == "true"
		space:set({
			icon = { highlight = selected },
			label = { highlight = selected },
			background = { border_color = selected and colors.black or colors.bg2 },
		})
	end)
end

local space_window_observer = sbar.add("item", {
	drawing = false,
	updates = true,
})

space_window_observer:subscribe("space_windows_change", function(env)
	local icon_line = ""
	local no_app = true
	for app, _ in pairs(env.INFO.apps) do
		no_app = false
		local lookup = app_icons[app]
		local icon = (lookup == nil) and app_icons["Default"] or lookup
		icon_line = icon_line .. icon
	end

	sbar.animate("tanh", 10, function()
		spaces[env.INFO.space]:set({
			label = {
				string = icon_line,
				drawing = not no_app,
			},
		})
	end)
end)
