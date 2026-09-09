-- ctrl+space is herdr's prefix, so it never reaches nvim. Trigger completion
-- with <C-x> instead — that costs vim's built-in ins-completion submode
-- (<C-x><C-f>, <C-x><C-o>, ...), which blink's sources already cover.
return {
  "saghen/blink.cmp",
  opts = {
    keymap = {
      ["<C-x>"] = { "show", "show_documentation", "hide_documentation" },
      ["<C-Space>"] = {},
    },
  },
}
