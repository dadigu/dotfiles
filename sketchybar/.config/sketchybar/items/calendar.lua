local settings = require("settings")
local colors = require("colors")

sbar.add("item", { position = "right", width = settings.group_paddings })

local cal = sbar.add("item", {
  icon = {
    color = colors.white,
    padding_left = 8,
    font = {
      style = settings.font.style_map["Heavy"],
      size = 13.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    align = "right",
    font = {
      style = settings.font.style_map["Semibold"],
      size = 13.0,
    },
  },
  position = "right",
  update_freq = 30,
  background = { color = colors.bg1 },
  padding_left = 1,
  padding_right = 1,
  click_script = "open -a 'Calendar'",
})

sbar.add("bracket", { cal.name }, {
  background = { color = colors.transparent },
})

sbar.add("item", { position = "right", width = settings.group_paddings })

cal:subscribe({ "forced", "routine", "system_woke" }, function(env)
  cal:set({ icon = os.date("%d %b"), label = os.date("%H:%M") })
end)
