local widgets = require("helpers.widgets")

-- Center widgets (no bracket)
require("items.widgets.event")

-- Right-side widgets with layout
local datetime = require("items.widgets.datetime")
widgets.bracket(datetime)

local battery = require("items.widgets.battery")
widgets.bracket(battery)

local wifi = require("items.widgets.wifi")
widgets.bracket(wifi)

local volume = require("items.widgets.volume")
widgets.bracket(volume[1], { volume[1].name, volume[2].name })

local cpu = require("items.widgets.cpu")
widgets.bracket(cpu)

local ram = require("items.widgets.ram")
widgets.bracket(ram)

local docker = require("items.widgets.docker")
widgets.bracket(docker)

-- Notifications group: shared bracket
local github  = require("items.widgets.github")
local linear  = require("items.widgets.linear")
local ferdium = require("items.widgets.ferdium")
local brew    = require("items.widgets.brew")

local notification_items = {}
if github then table.insert(notification_items, github.name) end
if linear then table.insert(notification_items, linear.name) end
if ferdium then table.insert(notification_items, ferdium.name) end
if brew then table.insert(notification_items, brew.name) end
if #notification_items > 0 then
  widgets.bracket("widgets.notifications", notification_items)
end
