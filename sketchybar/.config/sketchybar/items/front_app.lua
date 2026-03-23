local colors = require("colors")
local settings = require("settings")

sbar.add("item", "front_app.chevron", {
  display = "active",
  icon = {
    string = "❯",
    font = {
      style = settings.font.style_map["Bold"],
      size = settings.font.size.xl,
    },
    color = colors.magenta,
    padding_left = 4,
    padding_right = 0,
  },
  label = { drawing = false },
})

local front_app = sbar.add("item", "front_app", {
  display = "active",
  icon = {
    font = "sketchybar-app-font:Regular:16.0",
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
