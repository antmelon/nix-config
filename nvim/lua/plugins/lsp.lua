return {
  {
    "williamboman/mason.nvim",
    opts = {},
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    opts = {
      -- pyright omitted: requires npm, which is broken on this system
      -- install pyright system-wide via Nix and it will be picked up automatically
      ensure_installed = { "lua_ls", "clangd", "rust_analyzer" },
      automatic_enable = true,
    },
  },
  {
    "folke/lazydev.nvim",
    ft = "lua",
    opts = {
      library = {
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      -- Set blink.cmp capabilities for all servers globally
      vim.lsp.config("*", {
        capabilities = require("blink.cmp").get_lsp_capabilities(),
      })

      -- clangd on NixOS can't find the standard library on its own (there is no
      -- /usr/include). --query-driver whitelists the nix gcc wrapper so clangd
      -- may interrogate it for the real glibc/libstdc++ header paths. This is
      -- inert on Arch/macOS: no /nix/store driver is ever matched there, so
      -- clangd keeps resolving headers natively. The NixOS-only companion lives
      -- in the machine-local ~/.config/clangd/config.yaml, which sets
      -- CompileFlags.Compiler to that gcc wrapper so clangd actually queries it.
      vim.lsp.config("clangd", {
        cmd = { "clangd", "--query-driver=/nix/store/*/bin/*,/etc/profiles/per-user/*/bin/*" },
      })

      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local map = vim.keymap.set
          local opts = { buffer = args.buf }
          map("n", "gd", vim.lsp.buf.definition, opts)
          map("n", "gD", vim.lsp.buf.declaration, opts)
          map("n", "gr", vim.lsp.buf.references, opts)
          map("n", "gi", vim.lsp.buf.implementation, opts)
          map("n", "K", vim.lsp.buf.hover, opts)
          map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
          map("n", "<leader>rn", vim.lsp.buf.rename, opts)
          map("n", "<leader>e", vim.diagnostic.open_float, opts)
          map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, opts)
          map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, opts)
        end,
      })
    end,
  },
}
