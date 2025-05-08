return {
  "nvim-lualine/lualine.nvim",
  opts = {
    options = {
      section_separators = { left = "", right = "" },
    },
    sections = {
      lualine_a = { { "mode", separator = { left = "" }, right_padding = 2 } },
      -- Remove clock from lualine
      lualine_z = {},
    },
  },
}
