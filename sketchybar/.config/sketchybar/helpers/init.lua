-- Add the sketchybar Lua module to the package cpath
package.cpath = package.cpath .. ";/Users/" .. os.getenv("USER") .. "/.local/share/sketchybar_lua/?.so"

-- Also check the helpers directory for the compiled module
local config_dir = os.getenv("CONFIG_DIR") or os.getenv("HOME") .. "/.config/sketchybar"
package.cpath = package.cpath .. ";" .. config_dir .. "/helpers/?.so"

-- Source .env for API keys
local env_file = os.getenv("HOME") .. "/dotfiles/.env"
local f = io.open(env_file, "r")
if f then
  for line in f:lines() do
    local key, value = line:match("^([%w_]+)=(.+)$")
    if key and value and not line:match("^#") then
      -- Set as environment variable for sbar.exec child processes
      os.execute("export " .. key .. "=" .. value)
      -- Store in a global table for Lua access
      ENV = ENV or {}
      ENV[key] = value
    end
  end
  f:close()
end
