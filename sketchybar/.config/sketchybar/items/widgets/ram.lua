local colors = require("colors")

local ram = sbar.add("item", "widgets.ram", {
  position = "right",
  updates = "on",
  update_freq = 5,
  icon = {
    string = "􀫦",
  },
  label = {
    string = "??%",
    width = 40,
    align = "right",
  },
})

ram:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("memory_pressure", function(output)
    local pages_free = tonumber(output:match("Pages free:%s+(%d+)") or 0)
    local pages_active = tonumber(output:match("Pages active:%s+(%d+)") or 0)
    local pages_inactive = tonumber(output:match("Pages inactive:%s+(%d+)") or 0)
    local pages_speculative = tonumber(output:match("Pages speculative:%s+(%d+)") or 0)
    local pages_wired = tonumber(output:match("Pages wired down:%s+(%d+)") or 0)
    local pages_occupied = tonumber(output:match("Pages occupied by compressor:%s+(%d+)") or 0)

    local total = pages_free + pages_active + pages_inactive + pages_speculative + pages_wired + pages_occupied
    if total == 0 then return end

    local used = pages_active + pages_wired + pages_occupied
    local pct = math.floor((used / total) * 100)

    local color = colors.white
    if pct > 70 then color = colors.orange end
    if pct > 85 then color = colors.red end

    ram:set({
      label = { string = pct .. "%", color = color },
      icon = { color = color },
    })
  end)
end)

ram:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

return ram
