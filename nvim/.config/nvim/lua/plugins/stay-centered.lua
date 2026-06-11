return {
  "arnamak/stay-centered.nvim",
  -- Load on VeryLazy so the Snacks toggle can be registered up front,
  -- which is what gives the which-key on/off switch icon.
  event = "VeryLazy",
  opts = {
    -- skip_filetypes = { "lua", "typescript" },
  },
  config = function(_, opts)
    require("stay-centered").setup(opts)
    Snacks.toggle({
      name = "Stay Centered",
      get = function()
        return require("stay-centered").cfg.enabled
      end,
      set = function(state)
        require("stay-centered")[state and "enable" or "disable"]()
      end,
    }):map("<leader>ut")
  end,
}
