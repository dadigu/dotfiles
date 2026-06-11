-- gitsigns.nvim ships with LazyVim (for the gutter signs, hunk nav, staging).
-- Here we only enable its inline "current line blame": a grayed-out virtual-text
-- snippet at the end of the current line showing who last changed it and when —
-- like VSCode's GitLens line blame.
return {
  {
    "lewis6991/gitsigns.nvim",
    opts = {
      -- Show the blame virtual text on the line the cursor is on.
      current_line_blame = true,
      current_line_blame_opts = {
        virt_text = true,
        virt_text_pos = "eol", -- end of line; "right_align" pins it to the window edge
        delay = 300, -- ms after the cursor settles before the blame appears
        ignore_whitespace = false,
      },
      -- How the blame line reads. <author_time:%R> renders as "3 days ago".
      current_line_blame_formatter = "<author>, <author_time:%R> · <summary>",
    },
  },
  -- Toggle for the blame text on <leader>uB. This mirrors LazyVim's own
  -- <leader>uG "Git Signs" toggle: a second spec fragment whose opts function
  -- runs when gitsigns loads, registering a Snacks.toggle so which-key shows
  -- the on/off switch + live state.
  {
    "gitsigns.nvim",
    opts = function()
      Snacks.toggle({
        name = "Line Blame",
        get = function()
          return require("gitsigns.config").config.current_line_blame
        end,
        set = function(state)
          require("gitsigns").toggle_current_line_blame(state)
        end,
      }):map("<leader>uB")
    end,
  },
}
