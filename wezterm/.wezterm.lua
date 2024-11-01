-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = 'Catppuccin Frappe'

-- Font settings
config.font = wezterm.font("MonoLisa Nerd Font Mono")
config.font_size = 16
config.line_height = 1.2

-- Cursor
config.default_cursor_style = "SteadyBar"

-- Tab bar settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.colors = {
    tab_bar = {
        -- Setting the bar color to black
        -- background = '#000000',
    }
}

-- Various
config.window_close_confirmation = 'NeverPrompt'
config.send_composed_key_when_left_alt_is_pressed = true
config.harfbuzz_features = {"calt=0", "clig=0", "liga=0"} -- No font ligatures

return config
