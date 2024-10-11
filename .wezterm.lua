-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- Color scheme
config.color_scheme = 'Catppuccin Frappe'

-- Font settings
config.font = wezterm.font("MonoLisa Nerd Font Mono")
config.font_size = 18

-- Tab bar settings
config.enable_tab_bar = true
config.use_fancy_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

config.colors = {
    tab_bar = {
        -- Setting the bar color to black
        -- background = '#000000',
    }
}

return config