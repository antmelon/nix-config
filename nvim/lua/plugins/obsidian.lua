local vault = vim.fn.expand("~") .. "/Documents/Main Vault"

return {
  {
    "obsidian-nvim/obsidian.nvim",
    version = "*",
    ft = "markdown",
    cmd = "Obsidian",
    dependencies = { "nvim-lua/plenary.nvim" },
    opts = {
      -- `:Obsidian <subcommand>` only; the `:ObsidianFoo` forms go in 4.0.
      legacy_commands = false,

      workspaces = {
        { name = "Main Vault", path = vault },
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

      -- Vault uses wikilinks everywhere (see its CLAUDE.md).
      link = { style = "wiki", format = "shortest" },

      -- Frontmatter schemas vary by note type — don't auto-rewrite them.
      frontmatter = { enabled = false },

      -- Matches the vault-daily skill: 02 Daily/2026/11/11-06-26 Fri.md with
      -- created/updated frontmatter. Moment-style tokens since 3.x.
      daily_notes = {
        folder = "02 Daily",
        date_format = "YYYY/MM/MM-DD-YY ddd",
        default_tags = {},
        workdays_only = false,
        template = vim.fn.stdpath("config") .. "/templates/daily.md",
      },

      templates = {
        folder = "_Templates",
        date_format = "YYYY-MM-DD",
        time_format = "HH:mm",
        substitutions = {
          now = function() return os.date("%Y-%m-%dT%H:%M") end,
        },
      },

      attachments = { folder = "_Attachments" },

      picker = { name = "snacks.picker" },

      -- Checkboxes, bullets and link conceal in NERV colors (needs
      -- conceallevel, set for vault buffers below).
      ui = {
        enable = true,
        hl_groups = {
          ObsidianTodo = { bold = true, fg = "#ff6b1a" },
          ObsidianDone = { bold = true, fg = "#3ddc84" },
          ObsidianRightArrow = { bold = true, fg = "#ffc145" },
          ObsidianTilde = { bold = true, fg = "#ff3b30" },
          ObsidianImportant = { bold = true, fg = "#ff3b30" },
          ObsidianBullet = { bold = true, fg = "#ff6b1a" },
          ObsidianRefText = { underline = true, fg = "#ffc145" },
          ObsidianExtLinkIcon = { fg = "#ffc145" },
          ObsidianTag = { italic = true, fg = "#ff6b1a" },
          ObsidianBlockID = { italic = true, fg = "#8a7355" },
          ObsidianHighlightText = { bg = "#4a2a10" },
        },
      },

      callbacks = {
        enter_note = function()
          vim.opt_local.conceallevel = 2
          vim.opt_local.wrap = true
          vim.opt_local.linebreak = true
          vim.opt_local.spell = true
        end,
      },
    },
    keys = {
      { "<leader>oo", "<cmd>Obsidian quick_switch<CR>", desc = "Obsidian: quick switch" },
      { "<leader>os", "<cmd>Obsidian search<CR>", desc = "Obsidian: search" },
      { "<leader>on", "<cmd>Obsidian new<CR>", desc = "Obsidian: new note" },
      { "<leader>ot", "<cmd>Obsidian today<CR>", desc = "Obsidian: today's daily note" },
      { "<leader>oy", "<cmd>Obsidian yesterday<CR>", desc = "Obsidian: yesterday's daily note" },
      { "<leader>od", "<cmd>Obsidian dailies<CR>", desc = "Obsidian: list daily notes" },
      { "<leader>ob", "<cmd>Obsidian backlinks<CR>", desc = "Obsidian: backlinks" },
      { "<leader>ol", "<cmd>Obsidian links<CR>", desc = "Obsidian: links in note" },
      { "<leader>oT", "<cmd>Obsidian tags<CR>", desc = "Obsidian: tags" },
      { "<leader>op", "<cmd>Obsidian paste_img<CR>", desc = "Obsidian: paste image" },
      { "<leader>or", "<cmd>Obsidian rename<CR>", desc = "Obsidian: rename note" },
      { "<leader>oe", "<cmd>Obsidian template<CR>", desc = "Obsidian: insert template" },
      { "<leader>oc", "<cmd>Obsidian toggle_checkbox<CR>", desc = "Obsidian: toggle checkbox" },
      { "gf", "<cmd>Obsidian follow_link<CR>", desc = "Follow wikilink", ft = "markdown" },
    },
  },
}
