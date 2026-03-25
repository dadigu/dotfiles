local icons = require("icons")
local colors = require("colors")

local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  updates = "on",
  update_freq = 10,
  icon = {
    string = icons.cpu,
  },
  label = {
    string = "??%",
    width = 40,
    align = "right",
  },
})

cpu:subscribe({ "routine", "forced" }, function(env)
  sbar.exec("ps -A -o %cpu | awk 'NR>1 {s+=$1} END {printf \"%.0f\", s}'", function(cpu_sum)
    sbar.exec("sysctl -n hw.logicalcpu", function(cores)
      local total = math.floor((tonumber(cpu_sum) or 0) / (tonumber(cores) or 1))

      local color = colors.white
      if total > 60 then color = colors.orange end
      if total > 80 then color = colors.red end

      cpu:set({
        label = { string = total .. "%", color = color },
        icon = { color = color },
      })
    end)
  end)
end)

cpu:subscribe("mouse.clicked", function(env)
  sbar.exec("open -a 'Activity Monitor'")
end)

return cpu
