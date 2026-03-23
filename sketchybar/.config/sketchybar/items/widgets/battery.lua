local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
	position = "right",
	icon = {
		font = {
			style = settings.font.style_map["Regular"],
		},
	},
	updates = "on",
	update_freq = 180,
	popup = { align = "center" },
})

local popup_width = 250

-- Header: shows charging state with icon
local status = sbar.add("item", {
	position = "popup." .. battery.name,
	icon = {
		string = icons.battery.charging,
		font = { style = settings.font.style_map["Bold"] },
	},
	width = popup_width,
	align = "center",
	label = {
		font = {
			size = settings.font.size.xl,
			style = settings.font.style_map["Bold"],
		},
		string = "????????????",
	},
})

-- Helper to create popup info rows
local function popup_row(label, placeholder)
	return sbar.add("item", {
		position = "popup." .. battery.name,
		icon = {
			align = "left",
			string = label,
			width = popup_width / 2,
			color = colors.grey,
			font = { size = settings.font.size.sm },
		},
		label = {
			string = placeholder or "—",
			width = popup_width / 2,
			align = "right",
		},
	})
end

local time_left = popup_row("Time remaining:")
local health = popup_row("Health:")
local cycles = popup_row("Cycle count:")
local temp = popup_row("Temperature:")
local source = popup_row("Power source:")

sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.battery.padding", {
	position = "right",
	width = settings.group_paddings,
})

-- Icon update on routine / power change
battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
	sbar.exec("pmset -g batt", function(batt_info)
		local icon = "!"
		local label = "?"

		local found, _, charge = batt_info:find("(%d+)%%")
		if found then
			charge = tonumber(charge)
			label = charge .. "%"
		end

		local color = colors.green
		local on_ac = batt_info:find("AC Power")

		if on_ac then
			icon = icons.battery.charging
			color = colors.white
		else
			if found and charge > 80 then
				icon = icons.battery._100
			elseif found and charge > 60 then
				icon = icons.battery._75
			elseif found and charge > 40 then
				icon = icons.battery._50
			elseif found and charge > 20 then
				icon = icons.battery._25
				color = colors.orange
			else
				icon = icons.battery._0
				color = colors.red
			end
		end

		local lead = ""
		if found and charge < 10 then
			lead = "0"
		end

		battery:set({
			icon = { string = icon, color = color },
			label = { string = lead .. label, drawing = not on_ac },
		})
	end)
end)

-- Populate popup on click
local IOREG_CMD = [[ioreg -rn AppleSmartBattery 2>/dev/null | awk -F' = ' '
/"CycleCount" =/ && !/LastQmax|9C/ {print "cycles:" $2}
/"Temperature" =/ && !/Sample|Average|Min|Max/ {print "temp:" $2}
/"NominalChargeCapacity" =/ {print "capacity:" $2}
/"DesignCapacity" =/ && !/Fed/ {print "design:" $2}
/"FullyCharged" =/ {print "fully_charged:" $2}
/"IsCharging" =/ {print "charging:" $2}
/"ExternalConnected" =/ && !/Raw/ {print "ac:" $2}
']]

local function populate_popup()
	-- Time remaining from pmset
	sbar.exec("pmset -g batt", function(batt_info)
		local found, _, remaining = batt_info:find(" (%d+:%d+) remaining")
		time_left:set({ label = found and remaining .. "h" or "—" })
	end)

	-- All other metrics from a single ioreg call
	sbar.exec(IOREG_CMD, function(output)
		local data = {}
		for line in output:gmatch("[^\n]+") do
			local key, val = line:match("^(.-):(.*)")
			if key then data[key] = val end
		end

		-- Charging state header
		local is_charging = data.charging == "Yes"
		local is_fully_charged = data.fully_charged == "Yes"
		local on_ac = data.ac == "Yes"

		local status_text = "On Battery"
		local status_color = colors.white
		if is_fully_charged then
			status_text = "Fully Charged"
			status_color = colors.green
		elseif is_charging then
			status_text = "Charging"
			status_color = colors.green
		elseif on_ac then
			status_text = "Not Charging"
		end

		status:set({
			icon = { string = on_ac and icons.battery.charging or icons.battery._100 },
			label = { string = status_text, color = status_color },
		})

		-- Power source
		source:set({ label = on_ac and "AC Power" or "Battery" })

		-- Health: current max capacity vs design capacity
		local cap = tonumber(data.capacity)
		local design = tonumber(data.design)
		if cap and design and design > 0 then
			local pct = math.floor(cap / design * 100)
			local health_color = colors.green
			if pct < 80 then health_color = colors.red
			elseif pct < 90 then health_color = colors.orange end
			health:set({ label = { string = pct .. "%", color = health_color } })
		end

		-- Cycle count
		local cycle_count = tonumber(data.cycles)
		if cycle_count then
			cycles:set({ label = tostring(cycle_count) })
		end

		-- Temperature (ioreg gives centi-degrees)
		local raw_temp = tonumber(data.temp)
		if raw_temp then
			local celsius = string.format("%.1f°C", raw_temp / 100)
			temp:set({ label = celsius })
		end
	end)
end

battery:subscribe("mouse.clicked", function()
	if battery:query().popup.drawing == "off" then
		battery:set({ popup = { drawing = true } })
		populate_popup()
	else
		battery:set({ popup = { drawing = false } })
	end
end)

battery:subscribe("mouse.exited.global", function()
	battery:set({ popup = { drawing = false } })
end)
