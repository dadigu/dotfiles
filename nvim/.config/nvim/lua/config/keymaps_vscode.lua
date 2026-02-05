local map = vim.keymap.set
local opts = { noremap = true, silent = true }

map("i", "jj", "<Esc>", { silent = true })

map({ "n", "v" }, "<leader>t", "<cmd>lua require('vscode').action('workbench.action.terminal.toggleTerminal')<CR>")
map("n", "<leader>e", "<cmd>lua require('vscode').action('workbench.view.explorer')<CR>")
map("n", "<leader>E", "<cmd>lua require('vscode').action('revealInExplorer')<CR>")
