local map = vim.keymap.set
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
if vim.g.vscode then
  -- VSCode extension
else
  -- ordinary Neovim
  map("i", "jj", "<ESC>", { silent = true })
  map("i", "jk", "<cmd>w<cr><ESC>", { silent = true })

  -- OS clipboard
  map("v", "<leader>Y", '"+y', { silent = true, desc = "Yank to system clipboard " })
  map("n", "<leader>YY", '"+yy', { silent = true, desc = "Yank to system clipboard " })
  map({ "n", "v" }, "<leader>P", '"+p', { silent = true, desc = "Paste from system clipboard " })
end
