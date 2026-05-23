return {
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "sindrets/diffview.nvim",
    },
    opts = { integrations = { diffview = true } },
    keys = {
      { "<leader>gs", "<cmd>Neogit<CR>", desc = "Neogit" },
    },
  },
  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<CR>",          desc = "Diffview open" },
      { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "File history" },
      { "<leader>gx", "<cmd>DiffviewClose<CR>",         desc = "Diffview close" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    opts = {},
    keys = {
      { "]g",         function() require("gitsigns").next_hunk() end,   desc = "Next hunk" },
      { "[g",         function() require("gitsigns").prev_hunk() end,   desc = "Prev hunk" },
      { "<leader>ghs", function() require("gitsigns").stage_hunk() end,  desc = "Stage hunk" },
      { "<leader>ghr", function() require("gitsigns").reset_hunk() end,  desc = "Reset hunk" },
      { "<leader>gb",  function() require("gitsigns").blame_line() end,  desc = "Blame line" },
    },
  },
}
