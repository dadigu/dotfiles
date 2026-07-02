return {
  "snacks.nvim",
  opts = {
    -- Disable scroll animation
    scroll = {
      enabled = false,
    },
    -- Disable indent guides by default
    indent = {
      enabled = false,
    },
    -- Set width of zen editor
    styles = {
      zen = {
        width = 130,
      },
    },
    -- Custom hint bar under the picker search input. We set an explicit
    -- `footer` (not `footer_keys`, which can't resolve the action labels and
    -- just repeats the key) so each key shows what it does.
    picker = {
      win = {
        input = {
          -- Help while still typing (default `?` only works in normal mode).
          keys = {
            ["<c-?>"] = { "toggle_help_input", mode = { "i", "n" } },
          },
          footer = {
            { "  ", "SnacksFooter" },
            { " ⏎ ", "SnacksFooterKey" },
            { "open ", "SnacksFooterDesc" },
            { " ⌃s ", "SnacksFooterKey" },
            { "split ", "SnacksFooterDesc" },
            { " ⌃v ", "SnacksFooterKey" },
            { "vsplit ", "SnacksFooterDesc" },
            { " ⌃t ", "SnacksFooterKey" },
            { "tab ", "SnacksFooterDesc" },
            { " ⌃? ", "SnacksFooterKey" },
            { "help ", "SnacksFooterDesc" },
            { "  ", "SnacksFooter" },
          },
          footer_pos = "center",
        },
      },
    },
    -- Disable dimming lines around in zen mode
    zen = {
      toggles = {
        dim = false,
      },
      -- Keep the buffer bar (bufferline) visible in zen mode
      show = {
        tabline = true,
      },
    },
  },
}
