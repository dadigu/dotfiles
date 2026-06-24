-- =============================================================================
-- Aerospace workspaces module — visual twin of items/spaces.lua but for
-- Aerospace instead of yabai. Renders one pill per workspace with the app
-- icons of windows currently in it, highlights the focused workspace, and
-- click-focuses on tap.
-- =============================================================================
--
-- How it differs from items/spaces.lua
--   * yabai uses sketchybar's built-in `space` item type (fires `space_change`
--     and `space_windows_change` automatically). Aerospace doesn't hook into
--     that — we use plain `item`s and a custom event instead.
--   * Aerospace fires `aerospace_workspace_change` (a sketchybar event we
--     register here) via `exec-on-workspace-change` in aerospace.toml.
--   * App icons are queried with `aerospace list-windows --workspace N` on
--     each refresh rather than coming through an event payload.
--
-- Activation (when you're ready)
--   1. In sketchybar/.config/sketchybar/items/init.lua, replace
--        require("items.spaces")
--      with
--        require("items.aerospace")
--      Keep both during a transition if you like, but they'll fight over bar
--      space.
--   2. Make sure aerospace.toml contains the `exec-on-workspace-change`
--      block that triggers the custom event (already added there as part of
--      this migration).
--   3. `sketchybar --reload`.
--
-- Tunables
--   * `workspace_ids` below: edit to match what's defined in aerospace.toml.
--     If you adopt named workspaces (W, C, M, ...), put their names here.
--   * `display = "<n>"` on each workspace item is omitted, so all bars show
--     all workspaces. If you want per-monitor bars to only show their
--     assigned workspaces, set `display` per item or filter by monitor.
-- =============================================================================

local colors = require("colors")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

-- Register the custom event that aerospace.toml triggers via sketchybar CLI.
-- Payload: env.FOCUSED_WORKSPACE = the name of the now-focused workspace.
sbar.add("event", "aerospace_workspace_change")

-- Workspaces to render, with a per-workspace `display` pin so each monitor's
-- bar only shows its own workspaces. Sketchybar display numbering matches
-- `aerospace list-monitors` ordering.
--
-- Convention used here:
--   display 1 (laptop)        → workspaces 1, 2
--   display 2 (external #1)   → workspaces 3, 4
--   display 3 (external #2)   → workspaces 5, 6
--
-- When you're on the laptop alone, displays 2/3 don't exist so those pills
-- simply don't render. Should also stay in sync with the
-- [workspace-to-monitor-force-assignment] block in aerospace.toml.
local workspaces_config = {
  { id = "1", display = "1" },
  { id = "2", display = "1" },
  { id = "3", display = "2" },
  { id = "4", display = "2" },
  { id = "5", display = "3" },
  { id = "6", display = "3" },
}

local workspaces = {}

for _, wcfg in ipairs(workspaces_config) do
  local sid = wcfg.id
  local workspace = sbar.add("item", "aerospace.workspace." .. sid, {
    display = wcfg.display,
    icon = {
      string = sid,
      padding_left = 10,
      padding_right = 10,
      color = colors.grey,
      highlight_color = colors.green,
    },
    label = {
      padding_right = 10,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      drawing = false, -- hidden until we know the workspace has windows
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_color = colors.bg2,
      border_width = 2,
    },
    click_script = "aerospace workspace " .. sid,
  })

  workspaces[sid] = workspace

  sbar.add("bracket", { workspace.name }, {
    background = { color = colors.transparent },
  })

  sbar.add("item", "aerospace.workspace.padding." .. sid, {
    width = settings.group_paddings,
  })
end

-- Query Aerospace for the windows in a workspace and rebuild its icon line.
-- `--format '%{app-name}'` returns one app name per line, no pipes/IDs to parse.
local function refresh_workspace_icons(sid)
  sbar.exec(
    "aerospace list-windows --workspace " .. sid .. " --format '%{app-name}'",
    function(windows)
      local icon_line = ""
      local has_apps = false
      for app in (windows or ""):gmatch("[^\r\n]+") do
        local trimmed = app:match("^%s*(.-)%s*$")
        if trimmed and trimmed ~= "" then
          has_apps = true
          local lookup = app_icons[trimmed]
          local icon = (lookup == nil) and app_icons["Default"] or lookup
          icon_line = icon_line .. icon
        end
      end

      sbar.animate("tanh", 10, function()
        workspaces[sid]:set({
          label = {
            string = icon_line,
            drawing = has_apps,
          },
        })
      end)
    end
  )
end

local function refresh_all_icons()
  for _, wcfg in ipairs(workspaces_config) do
    refresh_workspace_icons(wcfg.id)
  end
end

local function on_workspace_change(focused)
  for _, wcfg in ipairs(workspaces_config) do
    local sid = wcfg.id
    local selected = sid == focused
    workspaces[sid]:set({
      icon = { highlight = selected },
      label = { highlight = selected },
      background = {
        border_color = selected and colors.black or colors.bg2,
      },
    })
  end
  refresh_all_icons()
end

-- Hidden observer item — listens for events and dispatches refreshes.
-- `update_freq = 5` polls every 5s; this catches cases the event-driven
-- subscriptions miss (e.g. new windows that race ahead of front_app_switched,
-- or windows that move workspaces without changing focus). Cheap because
-- refresh just runs `aerospace list-windows` which is near-instant.
local listener = sbar.add("item", {
  drawing = false,
  updates = true,
  update_freq = 5,
})

listener:subscribe("routine", function()
  refresh_all_icons()
end)

listener:subscribe("aerospace_workspace_change", function(env)
  on_workspace_change(env.FOCUSED_WORKSPACE or "")
end)

listener:subscribe("front_app_switched", function()
  refresh_all_icons()
end)

-- Initial paint at startup: ask Aerospace which workspace is focused and
-- highlight it. Falls back gracefully if Aerospace isn't running yet.
sbar.exec("aerospace list-workspaces --focused", function(focused)
  local trimmed = (focused or ""):match("^%s*(.-)%s*$")
  if trimmed and trimmed ~= "" then
    on_workspace_change(trimmed)
  else
    refresh_all_icons()
  end
end)
