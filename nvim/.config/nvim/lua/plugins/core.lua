return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin-macchiato",
    },
  },
  {
    "catppuccin",
    opts = {
      transparent_background = true,
      -- Color Vue component tags (<MyButton />) distinctly from plain HTML tags.
      -- Volar (vue_ls) emits a `component` semantic token; we just give it a color.
      custom_highlights = function(colors)
        return {
          -- Vue component tags (<MyButton />) — distinct from plain HTML tags.
          ["@lsp.type.component"] = { fg = colors.pink },
          -- Bound prop / directive arg names (:label, :key, @click) — distinct
          -- from the yellow static attrs and no longer naked white. Vue-scoped,
          -- so it doesn't recolor TS object-member access (obj.foo).
          ["@variable.member.vue"] = { fg = colors.yellow },
          -- Vue directives (v-if, v-for, v-show, ...) — purple, distinct from
          -- yellow static attrs. Paired with after/queries/vue/highlights.scm.
          ["@keyword.directive.vue"] = { fg = colors.mauve },
          -- Slot shorthand names (#default, #header) — muted gray instead of
          -- plain white. Vue-scoped, so it doesn't touch TS variables.
          ["@variable.vue"] = { fg = colors.subtext0 },
          -- Slot-destructured vars (#default="{ slotVar }") and their template
          -- usages — Volar's `local` modifier uniquely marks them, so this won't
          -- hit prop-passed values, v-for vars, or script refs. Vue-scoped.
          ["@lsp.typemod.variable.local.vue"] = { fg = colors.peach },
        }
      end,
    },
  },
}
