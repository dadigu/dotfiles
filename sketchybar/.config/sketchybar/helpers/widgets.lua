local colors = require("colors")
local settings = require("settings")

local M = {}

-- Add bracket background + padding after a right-side widget
function M.bracket(item, names)
	names = names or { item.name }
	sbar.add("bracket", item.name .. ".bracket", names, {
		background = { color = colors.bg1 },
	})
	sbar.add("item", item.name .. ".padding", {
		position = "right",
		width = settings.group_paddings,
	})
end

-- Create a popup info row with label on left, value on right
function M.popup_row(parent, label, placeholder)
	return sbar.add("item", {
		position = "popup." .. parent.name,
		icon = {
			align = "left",
			string = label,
			width = settings.popup_width / 2,
			color = colors.grey,
			font = { size = settings.font.size.sm },
		},
		label = {
			string = placeholder or "—",
			width = settings.popup_width / 2,
			align = "right",
		},
	})
end

return M
