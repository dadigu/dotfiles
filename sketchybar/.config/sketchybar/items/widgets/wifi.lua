local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local wifi = sbar.add("item", "widgets.wifi", {
	position = "right",
	icon = { string = icons.wifi.connected },
	label = { drawing = false },
	update_freq = 10,
	updates = "on",
	popup = { align = "center" },
})

local popup_width = 250

-- Helper to create popup info rows
local function popup_row(label, placeholder)
	return sbar.add("item", {
		position = "popup." .. wifi.name,
		icon = {
			align = "left",
			string = label,
			width = popup_width / 2,
			color = colors.grey,
			font = { size = settings.font.size.sm },
		},
		label = {
			string = placeholder or "???.???.???.???",
			width = popup_width / 2,
			align = "right",
		},
	})
end

-- Popup items
local ssid = sbar.add("item", {
	position = "popup." .. wifi.name,
	icon = {
		string = icons.wifi.router,
		font = { style = settings.font.style_map["Bold"] },
	},
	width = popup_width,
	align = "center",
	label = {
		font = {
			size = settings.font.size.xl,
			style = settings.font.style_map["Bold"],
		},
		max_chars = 18,
		string = "????????????",
	},
})

local hostname = popup_row("Hostname:", "????????????")
local ip = popup_row("IP:")
local mask = popup_row("Subnet mask:")
local router = popup_row("Router:")
local ext_ip = popup_row("External IP:")
local vpn = popup_row("VPN:", "—")

sbar.add("bracket", "widgets.wifi.bracket", { wifi.name }, {
	background = { color = colors.bg1 },
})

sbar.add("item", "widgets.wifi.padding", {
	position = "right",
	width = settings.group_paddings,
})

-- Detect active connection: default route for VPN, first en* in scutil for physical interface
local function detect_connection(callback)
	sbar.exec("route -n get default 2>/dev/null | awk '/interface:/ {print $2}'", function(default_iface)
		default_iface = default_iface:match("^%s*(.-)%s*$") or ""
		local is_vpn = default_iface:match("^utun") ~= nil

		sbar.exec(
			"scutil --nwi 2>/dev/null | awk '/en[0-9]+ :/ {iface=$1} iface && /address/ {print iface, $3; exit}'",
			function(result)
				local iface, addr = result:match("^(%S+)%s+(%S+)")
				if not iface then
					callback("none", nil, nil, is_vpn)
				elseif iface == "en0" then
					callback("wifi", iface, addr, is_vpn)
				else
					callback("ethernet", iface, addr, is_vpn)
				end
			end
		)
	end)
end

-- Look up the macOS network service name for a device (e.g. en7 -> "Dell Universal Dock D6000")
local function get_service_name(iface, callback)
	sbar.exec(
		'networksetup -listallhardwareports | awk \'/Hardware Port:/{port=$0; gsub(/Hardware Port: /,"",port)} /Device: '
			.. iface
			.. "/{print port}'",
		callback
	)
end

local function update_icon()
	detect_connection(function(kind, _, _, is_vpn)
		local color = is_vpn and colors.green or colors.white
		if kind == "ethernet" then
			wifi:set({ icon = { string = icons.wifi.ethernet, color = color } })
		elseif kind == "wifi" then
			wifi:set({ icon = { string = icons.wifi.connected, color = color } })
		else
			wifi:set({ icon = { string = icons.wifi.disconnected, color = colors.red } })
		end
	end)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, update_icon)

local function populate_popup()
	sbar.exec("networksetup -getcomputername", function(r)
		hostname:set({ label = r })
	end)
	sbar.exec("curl -s --max-time 3 ifconfig.me", function(r)
		ext_ip:set({ label = r })
	end)

	detect_connection(function(kind, iface, addr, is_vpn)
		vpn:set({
			label = {
				string = is_vpn and "Active" or "Inactive",
				color = is_vpn and colors.green or colors.red,
			},
		})

		if kind == "none" then
			ssid:set({ icon = { string = icons.wifi.disconnected }, label = { string = "No Connection" } })
			ip:set({ label = "—" })
			mask:set({ label = "—" })
			router:set({ label = "—" })
			return
		end

		ip:set({ label = addr })

		get_service_name(iface, function(service)
			service = service:match("^%s*(.-)%s*$") or ""

			if kind == "wifi" then
				ssid:set({ icon = { string = icons.wifi.router } })
				sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : ' '/ SSID : / {print $2}'", function(r)
					ssid:set({ label = r })
				end)
			else
				ssid:set({ icon = { string = icons.wifi.ethernet }, label = { string = service } })
			end

			if service ~= "" then
				sbar.exec("networksetup -getinfo '" .. service .. "' | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(r)
					mask:set({ label = r })
				end)
				sbar.exec("networksetup -getinfo '" .. service .. "' | awk -F 'Router: ' '/^Router: / {print $2}'", function(r)
					router:set({ label = r })
				end)
			end
		end)
	end)
end

local function copy_label_to_clipboard(env)
	local label = sbar.query(env.NAME).label.value
	sbar.exec('echo "' .. label .. '" | pbcopy')
	sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
	sbar.delay(1, function()
		sbar.set(env.NAME, { label = { string = label, align = "right" } })
	end)
end

wifi:subscribe("mouse.clicked", function()
	if wifi:query().popup.drawing == "off" then
		wifi:set({ popup = { drawing = true } })
		populate_popup()
	else
		wifi:set({ popup = { drawing = false } })
	end
end)

wifi:subscribe("mouse.exited.global", function()
	wifi:set({ popup = { drawing = false } })
end)

local popup_items = { ssid, hostname, ip, mask, router, ext_ip, vpn }
for _, item in ipairs(popup_items) do
	item:subscribe("mouse.clicked", copy_label_to_clipboard)
end
