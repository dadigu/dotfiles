local icons = require("icons")
local colors = require("colors")

-- How many minutes before an event to show it in the bar
local SHOW_BEFORE_MIN = 30

local cal = sbar.add("item", "widgets.calendar_event", {
	position = "q",
	icon = {
		string = icons.linear.calendar,
		color = colors.yellow,
	},
	label = {
		string = "",
	},
	drawing = false,
	update_freq = 60,
	updates = "on",
	click_script = "open -a 'Calendar'",
})

local is_visible = false

local function animate_in(icon_color, label)
	-- Set initial state: invisible and offset
	cal:set({
		drawing = true,
		y_offset = -20,
		icon = { color = colors.with_alpha(icon_color, 0.0) },
		label = { string = label, color = colors.with_alpha(colors.white, 0.0) },
	})
	-- Animate to final state
	sbar.animate("tanh", 15, function()
		cal:set({
			y_offset = 0,
			icon = { color = icon_color },
			label = { color = colors.white },
		})
	end)
end

local function update_event()
	sbar.exec("icalPal eventsRemaining -o json 2>/dev/null", function(events)
		if type(events) ~= "table" or #events == 0 then
			cal:set({ drawing = false })
			is_visible = false
			return
		end

		local now = os.time()

		-- Find the next non-all-day event within the threshold
		local next_event = nil
		for _, e in ipairs(events) do
			if e.all_day == 0 and e.sseconds then
				local mins_until = (e.sseconds - now) / 60
				-- Show if event starts within threshold, or is currently ongoing
				if mins_until <= SHOW_BEFORE_MIN and e.eseconds > now then
					next_event = e
					break
				end
			end
		end

		if not next_event then
			cal:set({ drawing = false })
			is_visible = false
			return
		end

		local mins_until = (next_event.sseconds - now) / 60
		local title = next_event.title or "Event"
		if #title > 20 then
			title = title:sub(1, 18) .. ".."
		end

		local time_str = os.date("%H:%M", next_event.sseconds)
		local label

		if mins_until <= 0 then
			-- Event is ongoing
			local mins_left = math.floor((next_event.eseconds - now) / 60)
			label = title .. "  ·  " .. mins_left .. "m left"
		elseif mins_until <= 5 then
			label = title .. "  ·  in " .. math.ceil(mins_until) .. "m"
		else
			label = title .. "  ·  " .. time_str
		end

		local icon_color = colors.yellow
		if mins_until <= 0 then
			icon_color = colors.green
		elseif mins_until <= 5 then
			icon_color = colors.red
		elseif mins_until <= 15 then
			icon_color = colors.orange
		end

		if not is_visible then
			animate_in(icon_color, label)
			is_visible = true
		else
			cal:set({
				icon = { color = icon_color },
				label = { string = label },
			})
		end
	end)
end

cal:subscribe({ "routine", "forced", "system_woke" }, update_event)
