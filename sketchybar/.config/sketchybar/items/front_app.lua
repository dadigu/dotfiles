local colors = require("colors")
local settings = require("settings")

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = {
    font = "sketchybar-app-font:Regular:16.0",
    color = colors.white,
  },
  label = {
    font = {
      style = settings.font.style_map["Black"],
      size = 12.0,
    },
  },
  updates = true,
})

local app_icons = require("helpers.app_icons")

front_app:subscribe("front_app_switched", function(env)
  local lookup = app_icons[env.INFO]
  local icon = (lookup == nil) and app_icons["Default"] or lookup
  front_app:set({
    icon = { string = icon },
    label = { string = env.INFO },
  })
end)
