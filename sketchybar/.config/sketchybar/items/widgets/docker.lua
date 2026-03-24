local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local docker = sbar.add("item", "widgets.docker", {
	position = "right",
	icon = {
		string = ":docker:",
		font = "sketchybar-app-font:Regular:16.0",
		color = colors.grey,
	},
	label = { drawing = false },
	update_freq = 180,
	updates = "on",
	popup = { align = "center" },
})

local popup_width = 300
local PATH = 'export PATH="$PATH:/usr/local/bin"; '

-- Static loading item — always exists in the popup
local loading = sbar.add("item", "docker.c.loading", {
	position = "popup." .. docker.name,
	icon = {
		string = icons.loading .. "  Loading containers...",
		width = popup_width,
		align = "center",
		color = colors.grey,
	},
	label = { drawing = false },
})

local container_count = 0

-- Routine: just check container count for icon color
docker:subscribe({ "routine", "forced" }, function()
	sbar.exec(PATH .. "docker ps -q 2>/dev/null | wc -l | tr -d ' '", function(output)
		container_count = tonumber(output) or 0
		docker:set({ icon = { color = container_count > 0 and colors.cyan or colors.grey } })
	end)
end)

local function fetch_stats()
	-- Show loading, hide old stats
	loading:set({ drawing = true })
	sbar.remove("/docker.s\\..*/")

	sbar.exec(
		PATH .. 'docker stats --no-stream --format "{{.Name}}|{{.CPUPerc}}|{{.MemUsage}}" 2>/dev/null',
		function(output)
			loading:set({ drawing = false })

			if output == nil or output == "" then
				sbar.add("item", "docker.s.empty", {
					position = "popup." .. docker.name,
					icon = { string = "No running containers", width = popup_width, align = "center" },
					label = { drawing = false },
				})
				return
			end

			-- Header
			sbar.add("item", "docker.s.header", {
				position = "popup." .. docker.name,
				icon = {
					string = "Container",
					font = { style = settings.font.style_map["Bold"] },
					width = popup_width * 0.35,
					align = "left",
				},
				label = {
					string = "CPU       MEM",
					font = { style = settings.font.style_map["Bold"] },
					width = popup_width * 0.65,
					align = "right",
				},
				background = {
					height = 2,
					color = colors.grey,
					y_offset = -15,
				},
			})

			local i = 0
			for line in output:gmatch("[^\n]+") do
				local name, cpu, mem = line:match("^(.-)|(.-)|(.*)")
				if name then
					i = i + 1
					if #name > 18 then
						name = name:sub(1, 16) .. ".."
					end

					local mem_used = mem:match("^(.-)%s*/") or mem
					mem_used = mem_used:match("^%s*(.-)%s*$")

					local cpu_num = tonumber(cpu:match("([%d%.]+)")) or 0
					local color = colors.grey
					if cpu_num > 60 then
						color = colors.orange
					end
					if cpu_num > 80 then
						color = colors.red
					end

					sbar.add("item", "docker.s." .. i, {
						position = "popup." .. docker.name,
						icon = {
							string = name,
							width = popup_width * 0.35,
							align = "left",
							color = colors.white,
						},
						label = {
							string = cpu .. "   " .. mem_used,
							font = { size = settings.font.size.sm },
							width = popup_width * 0.65,
							align = "right",
							color = color,
						},
					})
				end
			end
		end
	)
end

docker:subscribe("mouse.clicked", function()
	if container_count == 0 then
		return
	end

	local should_open = docker:query().popup.drawing == "off"
	if should_open then
		docker:set({ popup = { drawing = true } })
		fetch_stats()
	else
		docker:set({ popup = { drawing = false } })
		sbar.remove("/docker.s\\..*/")
		loading:set({ drawing = true })
	end
end)

docker:subscribe("mouse.exited.global", function()
	docker:set({ popup = { drawing = false } })
	sbar.remove("/docker.s\\..*/")
	loading:set({ drawing = true })
end)

return docker
