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

widgets.bracket(brew)

local is_visible = false

local function update_brew()
	sbar.exec("/bin/zsh -c \"brew outdated -q 2>/dev/null | wc -l | tr -d ' '\"", function(count)
		local n = tonumber(count) or 0
		if n == 0 then
			brew:set({ drawing = false })
			is_visible = false
			return
		end

		if not is_visible then
			brew:set({
				drawing = true,
				y_offset = -20,
				icon = { color = colors.with_alpha(colors.yellow, 0.0) },
				label = { string = tostring(n), color = colors.with_alpha(colors.yellow, 0.0) },
			})
			sbar.animate("tanh", 15, function()
				brew:set({
					y_offset = 0,
					icon = { color = colors.yellow },
					label = { color = colors.yellow },
				})
			end)
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
