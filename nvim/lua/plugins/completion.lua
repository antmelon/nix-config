return {
  {
    "saghen/blink.cmp",
    dependencies = { "rafamadriz/friendly-snippets", "saghen/blink.lib" },
    version = false,
    opts = {
      keymap = { preset = "default" },
      appearance = { nerd_font_variant = "mono" },
      fuzzy = { implementation = "lua" },
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      completion = {
        documentation = { auto_show = true },
      },
    },
  },
}
