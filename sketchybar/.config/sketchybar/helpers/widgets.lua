local colors = require("colors")
local settings = require("settings")

local M = {}

-- Add bracket background + padding after a right-side widget or group
function M.bracket(item_or_name, names)
	local name = type(item_or_name) == "string" and item_or_name or item_or_name.name
	names = names or { name }
	sbar.add("bracket", name .. ".bracket", names, {
		background = { color = colors.bg1 },
	})
	sbar.add("item", name .. ".padding", {
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

-- Format an ISO timestamp (e.g. "2026-03-24T10:02:38Z") as relative time
function M.relative_time(timestamp)
	if not timestamp then return "" end
	local y, mo, d, h, mi, s = timestamp:match("(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)")
	if not y then return "" end
	local ts = os.time({ year = tonumber(y), month = tonumber(mo), day = tonumber(d), hour = tonumber(h), min = tonumber(mi), sec = tonumber(s) })
	local diff = os.time() - ts
	if diff < 3600 then return math.floor(diff / 60) .. "m"
	elseif diff < 86400 then return math.floor(diff / 3600) .. "h"
	else return math.floor(diff / 86400) .. "d" end
end

-- Animate an item into view (slide down + fade in)
function M.animate_in(item, icon_color, label_color)
	label_color = label_color or icon_color
	item:set({
		drawing = true,
		y_offset = -20,
		icon = { color = colors.with_alpha(icon_color, 0.0) },
		label = { color = colors.with_alpha(label_color, 0.0) },
	})
	sbar.animate("tanh", 20, function()
		item:set({
			y_offset = 0,
			icon = { color = icon_color },
			label = { color = label_color },
		})
	end)
end

return M
