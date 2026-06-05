return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    window = {
      position = "right",
    },
    filesystem = {
      filtered_items = {
        visible = true, -- show dotfiles/hidden by default; toggle with H
      },
    },
  },
}
