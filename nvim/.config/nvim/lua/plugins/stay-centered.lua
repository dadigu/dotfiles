return {
  "arnamak/stay-centered.nvim",
  opts = function()
    require("stay-centered").setup({
      -- Add any configurations here, like skip_filetypes if needed
      -- skip_filetypes = {"lua", "typescript"}
    })

    -- Define the keymap to toggle the stay-centered plugin
    vim.keymap.set("n", "<leader>ut", function()
      require("stay-centered").toggle()
      vim.notify("Toggled stay-centered", vim.log.levels.INFO)
    end, { desc = "Toggle stay-centered.nvim" })
  end,
}
