return {
  "shortcuts/no-neck-pain.nvim",
  opts = {
    width = 140,
    -- buffers = { right = { enabled = false } },
  },
  keys = {
    {
      "<leader>uN",
      "<cmd>NoNeckPain<cr>",
      desc = "Toggle no-neck-pain",
    },
  },
}
