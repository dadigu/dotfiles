local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local widgets = require("helpers.widgets")

local volume_percent = sbar.add("item", "widgets.volume1", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "??%",
    width = 40,
    align = "right",
    padding_left = -1,
  },
})

local volume_icon = sbar.add("item", "widgets.volume2", {
  position = "right",
  padding_right = -1,
  icon = {
    string = icons.volume._100,
    width = 0,
    align = "left",
    color = colors.grey,
    font = {
      style = settings.font.style_map["Regular"],
    },
  },
  label = {
    width = 25,
    align = "left",
    font = {
      style = settings.font.style_map["Regular"],
      size = settings.font.size.lg,
    },
  },
})

widgets.bracket(volume_icon, { volume_icon.name, volume_percent.name })

volume_percent:subscribe("volume_change", function(env)
  local volume = tonumber(env.INFO)
  local icon = icons.volume._0
  if volume > 60 then
    icon = icons.volume._100
  elseif volume > 30 then
    icon = icons.volume._66
  elseif volume > 10 then
    icon = icons.volume._33
  elseif volume > 0 then
    icon = icons.volume._10
  end

  local lead = ""
  if volume < 10 then lead = "0" end

  volume_icon:set({
    label = icon,
    label = { string = icon, color = volume == 0 and colors.red or colors.white },
  })
  volume_percent:set({
    label = { string = lead .. volume .. "%", drawing = volume > 0 },
  })
end)

local function volume_scroll(env)
  local delta = env.INFO.delta
  sbar.exec('osascript -e "set volume output volume (output volume of (get volume settings) + ' .. delta * 10.0 .. ')"')
end

volume_icon:subscribe("mouse.scrolled", volume_scroll)
volume_percent:subscribe("mouse.scrolled", volume_scroll)

volume_icon:subscribe("mouse.clicked", function(env)
  sbar.exec("osascript -e 'output muted of (get volume settings)'", function(muted)
    if muted:gsub("%s+", "") == "true" then
      sbar.exec("osascript -e 'set volume output muted false'")
      volume_icon:set({ label = { color = colors.white } })
      volume_percent:set({ label = { drawing = true } })
    else
      sbar.exec("osascript -e 'set volume output muted true'")
      volume_icon:set({ label = { color = colors.red } })
      volume_percent:set({ label = { drawing = false } })
    end
  end)
end)
