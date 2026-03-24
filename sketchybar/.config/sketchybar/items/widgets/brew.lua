local colors = require("colors")
local widgets = require("helpers.widgets")

-- Check every 2 hours (7200 seconds)
local CHECK_INTERVAL = 7200

local brew = sbar.add("item", "widgets.brew", {
	position = "right",
	icon = {
		string = "􀐛",
		color = colors.yellow,
	},
	drawing = false,
	update_freq = CHECK_INTERVAL,
	updates = "on",
	click_script = [[yabai -m rule --add label=taproom app='Ghostty' title='taproom' manage=off grid=10:8:1:1:6:8 && open -na Ghostty.app --args -e taproom -f Outdated && sleep 2 && yabai -m rule --remove taproom]],
})

local is_visible = false

local function update_brew()
	sbar.exec("/bin/zsh -c \"brew outdated -q 2>/dev/null | wc -l | tr -d ' '\"", function(count)
		local n = tonumber(count) or 0
		if n == 0 then
			brew:set({ drawing = false })
			is_visible = false
			return
		end

		brew:set({ label = { string = tostring(n) } })
		if not is_visible then
			widgets.animate_in(brew, colors.yellow)
			is_visible = true
		else
			brew:set({ label = { string = tostring(n) } })
		end
	end)
end

brew:subscribe({ "routine", "forced", "system_woke" }, update_brew)

brew:subscribe("mouse.clicked", function()
	brew:set({ drawing = false })
	is_visible = false
end)

return brew
