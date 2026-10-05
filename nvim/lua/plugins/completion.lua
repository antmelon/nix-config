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
    config = function(_, opts)
      -- Workaround for blink.cmp's nvim version shim in lua/blink/cmp/lib/utils.lua.
      -- It only expects `vim.Pos:to_cursor()` to return a `{ row, col }` table on
      -- nvim 0.13+, and wraps the result otherwise. This nightly (0.12.0-dev) already
      -- returns the table, so the wrap yields `{ { row, col } }` and every cursor move
      -- fails with `E5108: Argument "pos" must be a [row, col] array`.
      -- Remove once upstream gates this on behaviour instead of version.
      local utils = require("blink.cmp.lib.utils")
      function utils.vim_pos_to_cursor(pos)
        local row, col = pos:to_cursor()
        if type(row) == "table" then return row end
        return { row, col }
      end

      require("blink.cmp").setup(opts)
    end,
  },
}
