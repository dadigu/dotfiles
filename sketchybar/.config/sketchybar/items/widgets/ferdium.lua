local colors = require("colors")
local widgets = require("helpers.widgets")

local ferdium = sbar.add("item", "widgets.ferdium", {
	position = "right",
	icon = {
		string = "􀋚",
		color = colors.red,
	},
	drawing = false,
	update_freq = 30,
	updates = "on",
	click_script = "open -a 'Ferdium'",
})

local is_visible = false

local function update_badge()
	sbar.exec("lsappinfo -all info -only StatusLabel 'Ferdium' | sed -nr \"s/.*\\\"label\\\"=\\\"([^\\\"]*)\\\".*/\\1/p\"", function(badge)
		badge = (badge or ""):match("^%s*(.-)%s*$")
		local n = tonumber(badge)

		if not n or n == 0 then
			ferdium:set({ drawing = false })
			is_visible = false
			return
		end

		ferdium:set({ label = { string = tostring(n) } })
		if not is_visible then
			widgets.animate_in(ferdium, colors.red, colors.white)
			is_visible = true
		end
	end)
end

ferdium:subscribe({ "routine", "forced", "system_woke" }, update_badge)

return ferdium
