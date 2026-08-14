return {
  "lmilojevicc/herdr-splits.nvim",
  cond = function() return vim.env.HERDR_ENV == "1" end,
  -- Nav only: the resize actions (alt+h/j/k/l) are left unbound here and in
  -- herdr's config.toml, since alt+h/j/k/l belongs to yabai.
  opts = {},
  keys = {
    { "<C-h>", function() require("herdr-splits").move_cursor_left() end,  desc = "Pane left"  },
    { "<C-j>", function() require("herdr-splits").move_cursor_down() end,  desc = "Pane down"  },
    { "<C-k>", function() require("herdr-splits").move_cursor_up() end,    desc = "Pane up"    },
    { "<C-l>", function() require("herdr-splits").move_cursor_right() end, desc = "Pane right" },
  },
}
