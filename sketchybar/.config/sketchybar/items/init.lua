-- Detect which window manager is running and load the matching workspaces
-- module. This lets the same sketchybar config work for both yabai and
-- Aerospace — switch WMs and run `sketchybar --reload` (or have the WM do
-- it on startup) and the bar follows.
--
-- Precedence: Aerospace wins if both are somehow running, since the migration
-- target is Aerospace. If neither is running, no workspace module loads —
-- the rest of the bar still renders fine.
local function process_running(pattern)
  local handle = io.popen("pgrep -ix " .. pattern .. " >/dev/null 2>&1; echo $?")
  if not handle then return false end
  local result = handle:read("*a")
  handle:close()
  return (result or ""):match("^0") ~= nil
end

require("items.apple")

if process_running("AeroSpace") then
  require("items.aerospace")
elseif process_running("yabai") then
  require("items.spaces")
end

require("items.front_app")
require("items.widgets")
