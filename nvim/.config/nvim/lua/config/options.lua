-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
-- Set the clipboard option to use the system clipboard

vim.g.lazyvim_eslint_auto_format = true

-- Use the Snacks picker (modern LazyVim default). Without this, our install
-- (install_version 7) is grandfathered onto fzf-lua.
vim.g.lazyvim_picker = "snacks"

-- Unsync registries with OS clipboard
vim.opt.clipboard = ""
