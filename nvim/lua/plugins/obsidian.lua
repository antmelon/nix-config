return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    lazy = true,
    ft = "markdown",
    event = {
      "BufReadPre " .. vim.fn.expand("~") .. "/Documents/Main_Vault/Main_Vault/**.md",
      "BufNewFile " .. vim.fn.expand("~") .. "/Documents/Main_Vault/Main_Vault/**.md",
    },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "echasnovski/mini.pick",
    },
    opts = {
      workspaces = {
        {
          name = "Main_Vault",
          path = "~/Documents/Main_Vault/Main_Vault",
        },
      },

      notes_subdir = nil,
      new_notes_location = "current_dir",

      -- Filenames mirror the title verbatim (the vault never prepends UIDs).
      note_id_func = function(title)
        if title ~= nil and title ~= "" then
          return title
        end
        return tostring(os.time())
      end,

      -- Vault uses wikilinks everywhere (see CLAUDE.md).
      preferred_link_style = "wiki",
      wiki_link_func = "use_alias_only",

      -- Frontmatter schemas vary by note type — don't auto-rewrite them.
      disable_frontmatter = true,

      daily_notes = {
        folder = "02 Daily",
        -- Produces e.g. "2026/05/05-24-26 Sun" → 02 Daily/2026/05/05-24-26 Sun.md
        date_format = "%Y/%m/%m-%d-%y %a",
        default_tags = nil,
        template = nil,
      },

      templates = {
        folder = "_Templates",
        date_format = "%Y-%m-%d",
        time_format = "%H:%M",
      },

      attachments = {
        img_folder = "_Attachments",
      },

      completion = {
        nvim_cmp = false,
        blink = false,
        min_chars = 2,
      },

      picker = {
        name = "mini.pick",
      },

      -- Let render-markdown / treesitter handle conceals; built-in UI can fight conceallevel.
      ui = { enable = false },

      follow_url_func = function(url)
        vim.fn.jobstart({ "open", url })
      end,
    },
    keys = {
      { "<leader>oo", "<cmd>ObsidianQuickSwitch<CR>", desc = "Obsidian: quick switch" },
      { "<leader>os", "<cmd>ObsidianSearch<CR>",      desc = "Obsidian: search" },
      { "<leader>on", "<cmd>ObsidianNew<CR>",         desc = "Obsidian: new note" },
      { "<leader>ot", "<cmd>ObsidianToday<CR>",       desc = "Obsidian: today's daily note" },
      { "<leader>oy", "<cmd>ObsidianYesterday<CR>",   desc = "Obsidian: yesterday's daily note" },
      { "<leader>od", "<cmd>ObsidianDailies<CR>",     desc = "Obsidian: list daily notes" },
      { "<leader>ob", "<cmd>ObsidianBacklinks<CR>",   desc = "Obsidian: backlinks" },
      { "<leader>ol", "<cmd>ObsidianLinks<CR>",       desc = "Obsidian: links in note" },
      { "<leader>oT", "<cmd>ObsidianTags<CR>",        desc = "Obsidian: tags" },
      { "<leader>op", "<cmd>ObsidianPasteImg<CR>",    desc = "Obsidian: paste image" },
      { "<leader>or", "<cmd>ObsidianRename<CR>",      desc = "Obsidian: rename note" },
      { "<leader>oe", "<cmd>ObsidianTemplate<CR>",    desc = "Obsidian: insert template" },
      { "gf",         "<cmd>ObsidianFollowLink<CR>",  desc = "Follow wikilink",            ft = "markdown" },
    },
  },
}
