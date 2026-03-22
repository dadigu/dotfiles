local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = {
    string = icons.wifi.connected,
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
  },
  label = { drawing = false },
  popup = { align = "center" },
})

local popup_width = 250

local ssid = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = {
    font = { style = settings.font.style_map["Bold"] },
    string = icons.wifi.router,
  },
  width = popup_width,
  align = "center",
  label = {
    font = { size = 15, style = settings.font.style_map["Bold"] },
    max_chars = 18,
    string = "????????????",
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15,
  },
})

local hostname = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = { align = "left", string = "Hostname:", width = popup_width / 2 },
  label = { max_chars = 20, string = "????????????", width = popup_width / 2, align = "right" },
})

local ip = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = { align = "left", string = "IP:", width = popup_width / 2 },
  label = { string = "???.???.???.???", width = popup_width / 2, align = "right" },
})

local mask = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = { align = "left", string = "Subnet mask:", width = popup_width / 2 },
  label = { string = "???.???.???.???", width = popup_width / 2, align = "right" },
})

local router = sbar.add("item", {
  position = "popup." .. wifi.name,
  icon = { align = "left", string = "Router:", width = popup_width / 2 },
  label = { string = "???.???.???.???", width = popup_width / 2, align = "right" },
})

sbar.add("bracket", "widgets.wifi.bracket", { wifi.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  width = settings.group_paddings,
})

wifi:subscribe({ "wifi_change", "system_woke" }, function(env)
  sbar.exec("ipconfig getifaddr en0", function(result)
    local connected = result ~= ""
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.white or colors.red,
      },
    })
  end)
end)

local function hide_details()
  wifi:set({ popup = { drawing = false } })
end

local function toggle_details()
  local should_draw = wifi:query().popup.drawing == "off"
  if should_draw then
    wifi:set({ popup = { drawing = true } })
    sbar.exec("networksetup -getcomputername", function(r) hostname:set({ label = r }) end)
    sbar.exec("ipconfig getifaddr en0", function(r) ip:set({ label = r }) end)
    sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(r) ssid:set({ label = r }) end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Subnet mask: ' '/^Subnet mask: / {print $2}'", function(r) mask:set({ label = r }) end)
    sbar.exec("networksetup -getinfo Wi-Fi | awk -F 'Router: ' '/^Router: / {print $2}'", function(r) router:set({ label = r }) end)
  else
    hide_details()
  end
end

local function copy_label_to_clipboard(env)
  local label = sbar.query(env.NAME).label.value
  sbar.exec('echo "' .. label .. '" | pbcopy')
  sbar.set(env.NAME, { label = { string = icons.clipboard, align = "center" } })
  sbar.delay(1, function()
    sbar.set(env.NAME, { label = { string = label, align = "right" } })
  end)
end

wifi:subscribe("mouse.clicked", toggle_details)
wifi:subscribe("mouse.exited.global", hide_details)
ssid:subscribe("mouse.clicked", copy_label_to_clipboard)
hostname:subscribe("mouse.clicked", copy_label_to_clipboard)
ip:subscribe("mouse.clicked", copy_label_to_clipboard)
mask:subscribe("mouse.clicked", copy_label_to_clipboard)
router:subscribe("mouse.clicked", copy_label_to_clipboard)
