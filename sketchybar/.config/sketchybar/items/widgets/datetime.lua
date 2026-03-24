local settings = require("settings")

local datetime = sbar.add("item", "widgets.datetime", {
	position = "right",
	update_freq = 30,
	icon = {
		padding_left = 8,
		font = {
			style = settings.font.style_map["Heavy"],
		},
	},
	label = {
		padding_right = 8,
		align = "right",
	},
	click_script = "open -a 'Calendar'",
})

datetime:subscribe({ "forced", "routine", "system_woke" }, function()
	datetime:set({ icon = os.date("%d %b"), label = os.date("%H:%M") })
end)

return datetime
