local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

sbar.add("item", { width = 5 })

local apple = sbar.add("item", {
  icon = {
    font = { size = 16.0 },
    string = icons.apple,
    padding_right = 8,
    padding_left = 8,
  },
  label = { drawing = false },
  background = { color = colors.bg1 },
  padding_left = 1,
  padding_right = 1,
  click_script = "open -a 'System Settings'",
})

sbar.add("bracket", { apple.name }, {
  background = { color = colors.transparent },
})

sbar.add("item", { width = 7 })
