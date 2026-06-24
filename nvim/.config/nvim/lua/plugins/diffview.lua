return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewFileHistory", "DiffviewClose" },
  keys = {
    { "<leader>gD", "<cmd>DiffviewOpen<cr>", desc = "DiffView (working tree)" },
    { "<leader>gH", "<cmd>DiffviewFileHistory %<cr>", desc = "File history (current file)" },
    {
      "<leader>gB",
      function()
        -- Review the current branch against the default branch (origin first).
        local function base()
          for _, ref in ipairs({ "origin/main", "origin/master", "main", "master", "develop" }) do
            vim.fn.system({ "git", "rev-parse", "--verify", "--quiet", ref })
            if vim.v.shell_error == 0 then
              return ref
            end
          end
          return "HEAD~1"
        end
        vim.cmd("DiffviewOpen " .. base() .. "...HEAD")
      end,
      desc = "DiffView (branch vs default)",
    },
  },
  opts = {
    enhanced_diff_hl = true, -- richer word-level add/change/delete highlighting
    view = {
      default = { winbar_info = true }, -- revision info in a winbar above each side
      file_history = { winbar_info = true },
    },
    -- `q` closes Diffview, scoped to its own buffers (these maps are buffer-local).
    keymaps = {
      view = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
      file_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
      file_history_panel = { { "n", "q", "<cmd>DiffviewClose<cr>", { desc = "Close Diffview" } } },
    },
  },
}
