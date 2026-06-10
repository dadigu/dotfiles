return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      "scss", -- highlights <style lang="scss"> (also covers less/postcss/sass via injection)
    },
  },
}
