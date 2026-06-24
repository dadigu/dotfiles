local map = vim.keymap.set
-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
if vim.g.vscode then
  -- VSCode extension
  require("config.keymaps_vscode")
else
  -- ordinary Neovim
  map("i", "jj", "<ESC>", { silent = true })
  map("i", "jk", "<cmd>w<cr><ESC>", { silent = true })

  -- OS clipboard
  -- <leader>y is a standalone operator (no child maps) so which-key still
  -- shows the motion/text-object cheatsheet in operator-pending mode.
  -- (<leader>yiw, <leader>yiq, <leader>yi", <leader>ya{, <leader>y$, ...)
  map({ "n", "x" }, "<leader>y", '"+y', { silent = true, desc = "Yank to system clipboard" })
  -- whole line on a non-prefix key, mirroring vim's y/Y
  map("n", "<leader>Y", '"+yy', { silent = true, desc = "Yank line to system clipboard" })
  map({ "n", "v" }, "<leader>P", '"+p', { silent = true, desc = "Paste from system clipboard" })
end
