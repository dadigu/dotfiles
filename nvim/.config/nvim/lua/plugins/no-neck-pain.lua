return {
  "shortcuts/no-neck-pain.nvim",
  -- Load on VeryLazy (not on the keypress) so the Snacks toggle below can be
  -- registered up front — that's what gives the which-key on/off switch icon.
  event = "VeryLazy",
  opts = {
    width = 140,
    -- buffers = { right = { enabled = false } },
  },
  config = function(_, opts)
    require("no-neck-pain").setup(opts)
    -- Snacks.toggle = the same framework LazyVim's +ui toggles use, so this
    -- shows a live on/off icon in which-key instead of a static keymap.
    Snacks.toggle({
      name = "No-Neck-Pain",
      get = function()
        return _G.NoNeckPain ~= nil and _G.NoNeckPain.state ~= nil and _G.NoNeckPain.state.enabled or false
      end,
      set = function(state)
        require("no-neck-pain")[state and "enable" or "disable"]()
      end,
    }):map("<leader>uN")
  end,
}
