return {
  "swaits/zellij-nav.nvim",
  cond = function() return vim.env.ZELLIJ ~= nil end,
  event = "VeryLazy",
  opts = {},
  init = function()
    -- Ensure zellij returns to normal mode on nvim exit so autolock doesn't
    -- leave the pane stuck in locked mode.
    vim.api.nvim_create_autocmd("VimLeave", {
      pattern = "*",
      command = "silent !zellij action switch-mode normal",
    })
  end,
  keys = {
    { "<C-h>", "<cmd>ZellijNavigateLeftTab<cr>",  silent = true, desc = "Pane left"  },
    { "<C-j>", "<cmd>ZellijNavigateDown<cr>",     silent = true, desc = "Pane down"  },
    { "<C-k>", "<cmd>ZellijNavigateUp<cr>",       silent = true, desc = "Pane up"    },
    { "<C-l>", "<cmd>ZellijNavigateRightTab<cr>", silent = true, desc = "Pane right" },
  },
}
